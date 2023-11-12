#!/bin/bash
. ${MDS_SCRIPTS}/common.sh

function vifm_install_colorschemes() {
    TARGET_DIRECTORY=${HOME}/.config/vifm/colors
    install_cmd_if_missing git
    rm -rf ${TARGET_DIRECTORY} &> /dev/null
    git clone https://github.com/vifm/vifm-colors ~/.config/vifm/colors
    if [[ $(any_error $?) == "NO" ]]
    then
        cout success "Colorschemes installed"
    else
        cout error "Failed to install"
    fi
}

OPTION=$1
case ${OPTION} in
    --install-colorschemes)
        vifm_install_colorschemes
    ;;
    *)
        cout error "Invalid option"
    ;;
esac

