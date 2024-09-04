#!/bin/bash

function is_sourced() {
    local cmd=$(ps -ocmd -p $$ | tail -n 1)
    if [[ "${cmd}" == "bash" || "${cmd}" == "zsh --login" ]]
    then
        echo YES
    else
        echo NO
    fi
}

function cout() {
    color=$1
    shift
    message=$@
    case $color in
        red|error)
            echo -e "\e[1;31m[ERROR]\e[0m ${message}" 1>&2
            if [[ $(is_sourced) == NO ]]
            then
                exit 1
            else
                return 1
            fi
        ;;
        green|success)
            echo -e "\e[1;32m[SUCCESS]\e[0m ${message}" 1>&2
        ;;
        yellow|warning)
            echo -e "\e[1;33m[WARNING]\e[0m ${message}" 1>&2
        ;;
        debug)
            echo -e "\e[1;5;35m[DEBUG]\e[0m ${message}" 1>&2
        ;;
        blue|info)
            echo -e "\e[1;36m[INFO]\e[0m ${message}" 1>&2
        ;;
    esac
}

function get_shell() {
    ps -o command $$ | tail -n 1 | awk '{print $1}'
}

function get_file_extension() {
    missing_argument_validation 1 $1
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

function missing_argument_validation() {
    local function_name=${FUNCNAME[1]}
    local args_required=${1}
    if [[ -z ${args_required} ]]
    then
        cout error "Missing arguments for ${function_name}" || return $?
    fi

    shift
    local args_count=$#
    if (( ${args_required} > ${args_count} ))
    then
        cout error "Missing arguments for ${function_name} expected ${args_required} provided ${args_count}" || return $?
    fi

    local args_list=($(echo $@ | paste -d ' '))
    for (( i=0; i < ${#args_list[@]}; i+=1 ))
    do
        if [[ $(is_cmd_option ${args_list[${i}]}) == "YES" ]]
        then
            cout error "Invalid argument \"${args_list[${i}]}\" for ${function_name}" || return $?
        fi
    done
}

function update_repos() {
    if [[ ${IS_APT_UPDATE_PERFORMED} == YES ]]
    then
        return 0
    fi

    sudo apt update &> /dev/null
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
            cout info "Skiping download step."
            return
        else
            file_without_extension=$(get_filename_without_extension ${file_to_download})
            file_extension=$(get_file_extension ${file_to_download})
            renamed_file=${file_without_extension}_$(date +'%s').${file_extension}
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

function preparse_args() {
    declare -n map_ref=${1}
    shift
    while (( $# != 0 ))
    do
        declare -a arr=($(echo ${1}))
        local prefix=$(echo "${arr[*]}" | grep -o -e 'prefix=[a-zA-Z_-]\+' | awk -F '=' '{print $NF}')
        for (( i=0; i<${#arr[@]}; i+=1 ))
        do
            declare -a tmp=( $(echo ${arr[${i}]} | tr '=' ' ') )
            if [[ ${tmp:0:1} != '-' && -n "${prefix}" ]]
            then
                map_ref["${prefix}_${tmp[0]}"]="${tmp[1]}"
            else
                map_ref["${tmp[0]}"]="${tmp[1]}"
            fi
        done

        shift
    done

}

function print_args() {
    missing_argument_validation 1 ${1} || return 1
    declare -n map_ref=${1}
    cout info printing values
    local keys=(${!map_ref[*]})
    for (( i=0; i<${#keys[@]}; i+=1 ))
    do
        echo ${keys[i]} "${map_ref[${keys[${i}]}]}"
    done
}

function parse_args() {
    declare -n map_ref=${1}
    local append_extra_args=${2} # arguments not preceeding an option (n/y)
    shift
    shift

    while (( $# != 0 ))
    do
        local argval=${1}
        case ${argval} in
            -*|--*)
                if [[ "${argval:0:2}" == '--' && -n "${map_ref[${argval}]}" ]]
                then
                    argval="${map_ref[${argval}]}"
                fi

                if [[ -n ${map_ref[${argval}_prefix]} ]]
                then
                    local arg_value=''
                    if [[ ${map_ref[${argval}_args]} == yes ]]
                    then
                        while [[ "${2:0:1}" != '-' && -n "${2:0:1}" ]]
                        do
                            arg_value+=$([ -z "${arg_value}" ] && echo "${2}" || echo " ${2}")
                            shift
                        done

                        if [[ -z ${arg_value} ]]
                        then
                            cout error "Missing value for arg \"${argval}\""
                        fi
                    else
                        arg_value='YES'
                    fi

                    map_ref["${argval}"]=${arg_value}
                else
                    cout error "Unknown argument: ${argval}"
                fi
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
        local func_ref=${map_ref[${1}_func]}
        if [[ -n "${func_ref}" ]]
        then
            ${func_ref}
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
        #"args=yes prefix=-t func=func_t --title=-t" \
        #"args=no func=func_run prefix=-r --run=-r" \
        #"args=yes prefix=-f --file=-f"

    #parse_args map y "${@}"
    #exec_args_flow map -t -r
    #print_args map
#}

#some_main some values -t title_value -f "filename" --run end
