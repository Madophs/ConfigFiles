#!/bin/bash

source "${MDS_SCRIPTS}/utils/cout.sh"

[ ! -v REAL_SHELL ] && declare -g REAL_SHELL=$(ps -o command $$ | tail -n 1 | awk '{print $0}' | grep -o -e '^[\/a-z]\+' | awk -F '/' '{print $NF}')

function get_parent_pid_by_regex() {
    missing_argument_validation 1 "${1}"
    local regex="${1}"
    local -i expected_matches=$([ -n "${2}" ] && echo ${2} || echo 1)
    local -i matches=0

    local -i pid=$(ps -opid $$ | tail -n 1)
    while (( ${pid} != 1 ))
    do
        local cmd=$(ps -ocmd -p ${pid} | tail -n 1)
        echo "${cmd}" | grep -o "${regex}" &> /dev/null
        if [[ $(exit_is_zero $?) == YES ]]
        then
            matches=$(( matches += 1 ))
        fi

        if (( ${matches} >= ${expected_matches} ))
        then
            echo ${pid}
            return 0
        fi

        pid=$(ps -oppid -p ${pid} | tail -n 1)
    done
    echo ${pid}
}

function add_cmd_to_trap() {
    declare -i pid=${1}
    local trap_cmd="${2}"
    echo -e "${trap_cmd}" > "${MDS_TRAP_CMD}"
    kill -s SIGUSR1 "${pid}"
}

function get_shell() {
    ps -o command $$ | tail -n 1 | awk '{print $1}'
}

function get_file_extension() {
    missing_argument_validation 1 $1 || return 1
    filename=$1
    echo ${filename} | grep -o -e '\..*' | sed s/^\.//g
}

function get_filename_without_extension() {
    missing_argument_validation 1 $1
    filename=$1
    echo ${filename} | grep -i -o -e '^[a-z_0-9]\+'
}

function any_error() {
    cmd_output=$1
    if [[ ${cmd_output} == 0 ]]
    then
        echo "NO"
    else
        echo "YES"
    fi
}

function exit_is_zero() {
    if [[ $1 == 0 ]]
    then
        echo "YES"
    else
        echo "NO"
    fi
}

function exit_if_failed() {
    ret=$1
    msg=$2
    if [[ ${ret} != 0 ]];
    then
        cout error $msg
        exit 1
    fi
}

function is_installed() {
    package=$1
    dpkg -L ${package} &> /dev/null
    echo $?
}

function is_package_installed() {
    apt list -a $1 2> /dev/null | grep installed &> /dev/null
    exit_is_zero $?
}

function install_packages() {
    package_arr=($@)
    for ((i=0; i < $#; i+=1))
    do
        if [[ $(is_installed ${package_arr[$i]}) == 1 ]]
        then
            cout info "Installing: ${package_arr[$i]}"
            sleep 0.5
            sudo apt install -y ${package_arr[$i]}
            exit_if_failed $? "Failed to install ${package_arr[$i]}"
            cout success "Package ${package_arr[$i]} installed."
        fi
    done
}

function is_cmd_option() {
    ARG=${1}
    if [[ -n $(echo ${ARG} | grep -e '^-') ]]
    then
        echo "YES"
    else
        echo "NO"
    fi
}

function get_funcname() {
    if [[ ${REAL_SHELL} == 'zsh' ]]
    then
        echo ${funcstack[3]}
    else
        echo ${FUNCNAME[2]}
    fi
}

function missing_argument_validation() {
    local function_name=$(get_funcname)
    local args_required=${1}
    if [[ -z ${args_required} ]]
    then
        cout error "Missing arguments for ${function_name}"
    fi

    shift
    local args_count=$#
    if (( ${args_required} > ${args_count} ))
    then
        cout error "Missing arguments for ${function_name} expected ${args_required} provided ${args_count}"
    fi
}

function update_repos() {
    if [[ "${IS_APT_UPDATE_PERFORMED}" == YES ]]
    then
        return 0
    fi

    if (( $(get_parent_pid_by_regex "sudo apt update") != 1 ))
    then
        export IS_APT_UPDATE_PERFORMED="YES"
        return 0
    fi

    cout info "Refreshing the repositories..."
    sudo apt update
    if [[ $(any_error $?) == NO ]]
    then
        IS_APT_UPDATE_PERFORMED="YES"
    else
        cout error "Failed to update repos..."
    fi
}

function is_package_hold() {
    missing_argument_validation 1 $1
    package_name=$1
    results=$(apt-mark showhold ${package_name} | wc -l)
    if [[ ${results} > 0 ]]
    then
        echo "YES"
    else
        echo "NO"
    fi
}

function unhold_package() {
    missing_argument_validation 1 $1
    package_name=$1
    if [[ $(is_package_hold ${package_name}) == "YES" ]]
    then
        sudo apt-mark unhold ${package_name}
    fi
}

function hold_package() {
    missing_argument_validation 1 $1
    package_name=$1
    sudo apt-mark hold ${package_name}
}

function update_package() {
    sudo apt install --only-upgrade ${1}
}

function install_package() {
    missing_argument_validation 1 $1
    local exit_on_failure=$2
    if [[ -z ${IS_APT_UPDATE_PERFORMED} ]]
    then
        update_repos
    fi

    package_name=$1
    cout info "About to install ${package_name}"
    sleep 3
    sudo apt install -y --allow-downgrades ${package_name}
    if [[ $(any_error $?) == "YES" ]]
    then
        if [[ ${exit_on_failure} == "NO" ]]
        then
            cout danger "Failed to install ${package_name}"
        else
            cout error "Failed to install ${package_name}"
        fi
    fi
}

function install_package_if_missing() {
    missing_argument_validation 1 $1
    local exit_on_failure=$2
    local package=$1
    if [[ $(is_package_installed ${package}) == "NO" ]]
    then
        cout info "Package ${package} in not present in the system. Trying to install..."
        install_package ${package} ${exit_on_failure}
    fi
}

function snap_package_already_installed() {
    missing_argument_validation 1 $1
    package_name=$1
    snap list ${package_name} &> /dev/null
    if [[ $(any_error $?) == "NO" ]]
    then
        echo "YES"
    else
        echo "NO"
    fi
}

function install_package_with_snap() {
    missing_argument_validation 1 $1
    package_name=$1
    if [[ $(snap_package_already_installed ${package_name}) == "NO" ]]
    then
        cout info "About to install ${package_name} using snap"
        sudo snap install ${package_name}
    fi
}

function check_required_packages() {
    if [[ $# == 0 ]]
    then
        cout error "No packages specified"
    fi

    local package_list=($(echo $@ | paste -d ' '))
    for (( i=0; i < ${#package_list[@]}; i+= 1 ))
    do
        package_name=${package_list[${i}]}
        if [[ ! -x $(which ${package_name}) ]]
        then
            install_package ${package_name}
        fi
    done
}

function getWebsiteDOM() {
    missing_argument_validation 1 "${1}"
    local link="${1}"
    google-chrome --headless --disable-gpu --log-level=3 --disable-extensions --no-sandbox --enable-unsafe-swiftshader --password-store=basic --virtual-time-budget=10000 --dump-dom "${link}"
}

function download() {
    missing_argument_validation 2 $1 $2
    local download_link=${1}
    local download_dir=${2}
    wget -qq --no-clobber "${download_link}" -P "${download_dir}" || cout error "Failed to download: ${download_link}"
}

function clean_file() {
    missing_argument_validation 1 $1
    file_to_empty=$1
    touch ${file_to_empty} &> /dev/null
    truncate -s 0 ${file_to_empty} &> /dev/null
}

function add_desktop_app_entry() {
    missing_argument_validation 1 ${1}
    cat > "${MDS_HOME}/.local/share/applications/${1}.desktop" << EOF
[Desktop Entry]
Exec=${Exec}
GenericName=${GenericName}
Icon=${Icon}
Name=${Name}
Comment=${Comment}
NoDisplay=${NoDisplay:-false}
Path=${Path}
StartupNotify=${StartupNotify:-true}
Terminal=${Terminal:-false}
TerminalOptions=${TerminalOptions}
Type=${Type:-Application}
Categories=${Categories}
X-KDE-SubstituteUID=${X_KDE_SubstituteUID:-false}
X-KDE-Username=${X_KDE_Username}
EOF
}

function remove_desktop_app_entry() {
    missing_argument_validation 1 ${1}
    rm -f "${MDS_HOME}/.local/share/applications/${1}.desktop" &> /dev/null
}

