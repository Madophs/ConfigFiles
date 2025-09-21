#!/bin/bash

RED='\e[1;31m'
GREEN='\e[1;32m'
GREEN_DARK='\e[0;32m'
YELLOW='\e[1;33m'
BROWN='\e[0;33m'
BLUE='\e[1;34m'
BLUEG='\e[1;5;34m'
PURPLE='\e[1;35m'
PURPLEG='\e[1;5;35m'
CYAN='\e[1;36m'
CYAN_DARK='\e[0;36m'
BLK='\e[0;0m'

function print_stacktrace() {
    for ((i=1; i<=${#funcfiletrace[@]}; i+=1))
    do
        printf "${YELLOW}${funcstack[${i}]}${BROWN}..." >&2
        if (( i == 1 ))
        then
            printf "${GREEN}$(basename "${(%):-%x}")${BLK}\n" >&2
        else
            declare -a file_lineno=($(echo ${funcfiletrace[((i - 1))]} | tr ':' ' '))
            printf "${GREEN}$(basename ${file_lineno[1]}):${CYAN}${file_lineno[2]}${BLK}\n" >&2
        fi
    done

    if [[ ${REAL_SHELL} == 'zsh' ]] ; then return 0; fi;

    for ((i=0; i<${#BASH_SOURCE[@]}; i+=1))
    do
        printf "${YELLOW}${FUNCNAME[${i}]}${BROWN}...${GREEN}$(basename ${BASH_SOURCE[${i}]})" >&2

        # BASH_LINENO behave very strange when sourcing the scripts
        # it gives inaccurate lines numbers
        if [[ -z ${IS_SOURCED} || ${IS_SOURCED} == NO ]]
        then
            if (( i > 0 ))
            then
                printf ":${CYAN}${BASH_LINENO[$(( i - 1))]}${BLK}" >&2
            fi
        fi

        printf "\n" >&2
    done
}

function cout() {
    local color=$1
    shift
    local messsage="$@"
    case ${color} in
        red|error)
            echo -e "${BLUE}[${RED}ERROR${BLUE}]${BLK} ${messsage}" >&2
            print_stacktrace
            if [[ -z ${IS_SOURCED} || ${IS_SOURCED} == NO ]]
            then
                exit 1
            else
                kill -n 2 ${SHELL_PID} # SIGINT
            fi
        ;;
        fault)
            echo -e "${BLUE}[${PURPLE}FAULT${BLUE}]${BLK} ${messsage}" >&2
        ;;
        debug)
            echo -e "${BLUEG}[${PURPLE}DEBUG${BLUEG}]${BLK} ${messsage}" >&2
        ;;
        green|success)
            echo -e "${BLUE}[${GREEN}SUCCESS${BLUE}]${BLK} ${messsage}" >&2
        ;;
        yellow|warning)
            echo -e "${BLUE}[${YELLOW}WARNING${BLUE}]${BLK} ${messsage}" >&2
        ;;
        blue|info)
            echo -e "${BLUE}[${CYAN}INFO${BLUE}]${BLK} ${messsage}" >&2
        ;;
    esac
}

function on_error() {
    cout error "${@}"
}

function get_parent_pid_by_regex() {
    missing_argument_validation 1 "${1}"
    local regex="${1}"
    declare -i expected_matches=$([ -n "${2}" ] && echo ${2} || echo 1)
    declare -i matches=0

    typeset -i pid=$(ps -opid $$ | tail -n 1)
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
    if [[ "$(cat ${MDS_TRAP_CMD})" == "${trap_cmd}" ]]
    then
        return 1
    fi
    echo -e "${trap_cmd}" > ${MDS_TRAP_CMD}
    kill -n 35 ${pid}
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

    local args_list=($(echo $@ | paste -d ' '))
    for (( i=0; i < ${#args_list[@]}; i+=1 ))
    do
        if [[ $(is_cmd_option ${args_list[${i}]}) == "YES" ]]
        then
            cout error "Invalid argument \"${args_list[${i}]}\" for ${function_name}"
        fi
    done
}

function update_repos() {
    if [[ "${IS_APT_UPDATE_PERFORMED}" == YES ]]
    then
        return 0
    fi

    if (( $(get_parent_pid_by_regex "sudo apt update") != 1 ))
    then
        IS_APT_UPDATE_PERFORMED="YES"
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
    local download_link=$1
    local download_dir=$2
    mkdir -p ${download_dir}

    local file_to_download=$(echo ${download_link} | awk -F '/' '{print $NF}')
    if [[ -f ${download_dir}/${file_to_download} ]]
    then
        cout info "File ${file_to_download} already exists."
        cout warning "Download again? (y/n)"
        read -n 1 opt
        if [[ ${opt} != "y" && ${opt} != "Y" ]]
        then
            cout info "Skipping download step."
            return
        else
            file_without_extension="$(get_filename_without_extension ${file_to_download})"
            file_extension="$(get_file_extension ${file_to_download})"
            renamed_file="${file_without_extension}_$(date +'%s').${file_extension}"
            cout warning "Renaming file to ${renamed_file}"
            mv ${download_dir}/${file_to_download} ${download_dir}/${renamed_file}
        fi
    fi

    install_package_if_missing axel
    axel --alternate --output=${download_dir} ${download_link}
    if [[ $(any_error $?) == "YES" ]]
    then
        cout error "Failed to download ${download_link}"
    fi
}

function clean_file() {
    missing_argument_validation 1 $1
    file_to_empty=$1
    touch ${file_to_empty} &> /dev/null
    truncate -s 0 ${file_to_empty} &> /dev/null
}

function set_apt_hook() {
    missing_argument_validation 2 "${1}" "${2}"
    local package_name=${1}
    local option="${2}"
    local apt_hook="/etc/apt/apt.conf.d/05hook-${package_name}"
    sudo touch ${apt_hook}
    sudo truncate -s 0 ${apt_hook}
    echo 'APT::Update::Post-Invoke {"export MDS_SCRIPTS={{scripts}};export MDS_TRAP_CMD={{trap}};${MDS_SCRIPTS}/third_party/{{package}}.sh {{option}};";};' \
        | sed -e "s|{{package}}|${package_name}|g" -e "s|{{option}}|${option}|g" -e "s|{{scripts}}|${MDS_SCRIPTS}|g" -e "s|{{trap}}|${MDS_TRAP_CMD}|g" \
        | sudo tee -a ${apt_hook} &> /dev/null
}

function remove_apt_hook() {
    missing_argument_validation 1 ${1}
    local package_name="${1}"
    local apt_hook="/etc/apt/apt.conf.d/05hook-${package_name}"
    sudo rm "${apt_hook}"
}

function preparse_args() {
    declare -n map_ref=${1}
    shift
    while (( $# != 0 ))
    do
        declare -a arr=($(echo ${1}))
        local option=$(echo "${arr[*]}" | grep -o -e 'option=[a-zA-Z_-]\+' | awk -F '=' '{print $NF}')
        for (( i=0; i<${#arr[@]}; i+=1 ))
        do
            declare -a tmp=( $(echo ${arr[@]:${i}:1} | tr '=' ' ') )
            if [[ ${tmp:0:1} != '-' && -n "${option}" ]]
            then
                map_ref["${option}_${tmp[@]:0:1}"]="${tmp[@]:1:1}"
            else
                map_ref["${tmp[@]:0:1}"]="${tmp[@]:1:1}"
            fi
        done

        if [[ -n "${option}" ]]
        then
            map_ref["${option}_avail"]=NO
        fi

        shift
    done
}

function get_array_keys() {
    declare -n array_ref=${1}
    if [[ ${REAL_SHELL} == 'zsh' ]]
    then
        echo ${(@k)array_ref}
    else
        echo ${!array_ref[*]}
    fi
}

function print_args() {
    missing_argument_validation 1 ${1} || return 1
    declare -n map_ref=${1}
    cout info printing values
    local keys=($(get_array_keys map_ref))
    for (( i=0; i<${#keys[@]}; i+=1 ))
    do
        echo "${keys[@]:${i}:1}" "${map_ref[${keys[@]:${i}:1}]}"
    done
}

function parse_args() {
    declare -n map_ref=${1}
    local append_extra_args=${2} # arguments not preceeding an option (n/y)
    map_ref["extra"]=""
    shift
    shift

    while (( $# != 0 ))
    do
        local argval=${1}
        case ${argval} in
            -*|--*)
                # Use short option instead of long option if available e.g use -f instead of --file
                if [[ "${argval:0:2}" == '--' && -n "${map_ref[${argval}]}" ]]
                then
                    argval="${map_ref[${argval}]}"
                fi

                # Check if option is present in map
                if [[ -z ${map_ref["${argval}_option"]} ]]
                then
                    cout error "Unknown argument: ${argval}"
                fi

                # Mark option as available [avail]
                if [[ -n ${map_ref["${argval}_avail"]} ]]
                then
                    map_ref["${argval}_avail"]=YES
                fi

                local arg_value=''
                if [[ ${map_ref["${argval}_args"]} == yes || ${map_ref["${argval}_args"]} == opt ]]
                then
                    # All all option's space-separated arguments
                    while [[ "${2:0:1}" != '-' && -n "${2:0:1}" ]]
                    do
                        arg_value+=$([ -z "${arg_value}" ] && echo "${2}" || echo " ${2}")
                        shift
                    done

                    if [[ -z ${arg_value} && ${map_ref["${argval}_args"]} == yes ]]
                    then
                        cout error "Missing value for arg \"${argval}\""
                    fi
                else
                    arg_value="YES"
                fi

                map_ref["${argval}"]="${arg_value}"
                shift
                ;;
            *)
                if [[ ${append_extra_args} == 'y' ]]
                then
                    map_ref["extra"]+="${argval} "
                else
                    cout error "Invalid argument: ${argval}"
                fi
                shift
            ;;
        esac
    done
}

function exec_args_flow() {
    declare -n map_ref=${1}
    shift
    while (( $# > 0 ))
    do
        local option=${1}
        if [[ ${map_ref["${option}_avail"]} == NO ]]
        then
            shift
            continue
        fi

        local func_ref=${map_ref["${option}_func"]}
        if [[ -n "${func_ref}" ]]
        then
            ${func_ref} map_ref
        fi
        shift
    done
}

#function func_t() {
    #echo "hi i'm in the function T"
#}

#function func_run() {
    #echo "About to run the file"
    #cout info -f value is ${map["-f"]}
#}

#function some_main() {
    #declare -A map
    #preparse_args map \
        #"args=yes option=-t func=func_t --title=-t" \
        #"args=no func=func_run option=-r --run=-r" \
        #"args=yes option=-f --file=-f"

    #parse_args map y "${@}"
    #exec_args_flow map -t -r
    #print_args map
#}

#some_main some values -t title_value -f "filename" --run end
