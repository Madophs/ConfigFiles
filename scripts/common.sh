#!/bin/bash

function cout() {
    color=$1
    shift
    message=$@
    case $color in
        red|error|danger)
        echo -e "\e[1;31m[ERROR]\e[0m ${message}"
        exit 1
        ;;
        green|success)
        echo -e "\e[1;32m[SUCCESS]\e[0m ${message}"
        ;;
        yellow|warning)
        echo -e "\e[1;33m[WARNING]\e[0m ${message}"
        ;;
        blue|info)
        echo -e "\e[1;34m[INFO]\e[0m ${message}"
        ;;
    esac
}

function get_file_extension() {
    missing_argument_validation 1 $1
    filename=$1
    echo $(echo ${filename} | grep -o -e '\..*')
}

function get_filename_without_extension() {
    missing_argument_validation 1 $1
    filename=$1
    file_extension=$(get_file_extension ${filename})
    echo $(echo ${filename} | sed s/${file_extension}//g)
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

function install_packages() {
    package_arr=($@)
    for ((i=0; i < $#; i+=1))
    do
        if [[ $(is_installed ${package_arr[$i]}) == 1 ]]; then
            cout white "Installing: ${package_arr[$i]}"
            sudo apt install -y ${package_arr[$i]}
            exit_if_failed $? "Failed to install ${package_arr[$i]}"
            cout success "[SUCCESS] Package ${package_arr[$i]} installed."
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
    function_name=${FUNCNAME[1]}
    args_required=${1}
    if [[ -z ${args_required} ]]
    then
        cout error "Missing arguments for ${function_name}"
    fi

    shift
    args_count=$#
    if [[ ${args_required} != ${args_count} ]]
    then
        cout error "Missing arguments for ${function_name}, expected ${args_required} provided ${args_count}"
    fi

    args_list=($(echo $@ | paste -d ' '))
    for (( i=0; i < ${#args_list[@]}; i+=1 ))
    do
        if [[ $(is_cmd_option ${args_list[${i}]}) == "YES" ]]
        then
            cout error "Invalid argument \"${args_list[${i}]}\" for ${function_name}"
        fi
    done
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

function install_package() {
    missing_argument_validation 1 $1
    if [[ -z ${IS_APT_UPDATE_PERFORMED} ]]
    then
        sudo apt update &> /dev/null
        IS_APT_UPDATE_PERFORMED="YES"
    fi

    package_name=$1
    cout info "About to install ${package_name}"
    sleep 3
    sudo apt install ${package_name}
    if [[ $(any_error $?) == "YES" ]]
    then
        cout error "Failed to install ${package_name}"
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

    package_list=($(echo $@ | paste -d ' '))
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
    download_link=$1
    download_dir=$2
    mkdir -p ${download_dir}

    file_to_download=$(echo ${download_link} | awk -F '/' '{print $NF}')
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
            renamed_file=${file_without_extension}_$(date +'%s')${file_extension}
            cout warning "Renaming file to ${renamed_file}"
            mv ${download_dir}/${file_to_download} ${download_dir}/${renamed_file}
        fi
    fi


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
