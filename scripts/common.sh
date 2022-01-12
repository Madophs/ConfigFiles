#!/bin/bash

function cout() {
    COLOR=$1
    shift
    MESSAGE=$@
    case $COLOR in
        red|error|danger)
            echo -e "\e[1;31m${MESSAGE} \e[0m"
        ;;
        green|success)
            echo -e "\e[1;32m${MESSAGE} \e[0m"
        ;;
        yellow|warning)
            echo -e "\e[1;33m${MESSAGE} \e[0m"
        ;;
        blue|info)
            echo -e "\e[1;34m${MESSAGE} \e[0m"
        ;;
        *)
            echo -e "${MESSAGE}"
        ;;
    esac
}

function exit_if_failed() {
    RET=$1
    MSG=$2
    if [[ ${RET} != 0 ]];
    then
        cout error $MSG
        exit 1
    fi
}

function is_installed() {
    PACKAGE=$1
    dpkg -L ${PACKAGE} &> /dev/null
    echo $?
}

function install_packages() {
    PACKAGE_ARR=($@)
    for ((i=0; i < $#; i+=1))
    do
        if [[ $(is_installed ${PACKAGE_ARR[$i]}) == 1 ]]; then
            cout white "Installing: ${PACKAGE_ARR[$i]}"
            sudo apt install -y ${PACKAGE_ARR[$i]}
            exit_if_failed $? "Failed to install ${PACKAGE_ARR[$i]}"
            cout success "[SUCCESS] Package ${PACKAGE_ARR[$i]} installed."
        fi
    done
}
