#!/bin/bash

source "${MDS_SCRIPTS}/common.sh"
DOWNLOAD_PAGE_URL=https://www.gitkraken.com/download
GIKTRAKEN_CURRENT_RELEASE_URL=https://help.gitkraken.com/gitkraken-desktop/current/
GITKRAKEN_DOWNLOAD_URL="https://api.gitkraken.dev/releases/production/linux/x64/active/gitkraken-amd64.deb"

function gitkraken_get_latest_version() {
    curl -L -s "${GIKTRAKEN_CURRENT_RELEASE_URL}" | grep -m 1 '#version' | grep -E -o '[0-9]+\.[0-9]+\.[0-9]+' | tail -n 1
}

function gitkraken_get_current_version() {
    if [[ -x "$(which gitkraken)" ]]
    then
        gitkraken --version
    fi
}

function gitkraken_install() {
    cout info "About to install gitkraken $(gitkraken_get_latest_version)"
    mkdir -p "/tmp/gitkraken"
    download "${GITKRAKEN_DOWNLOAD_URL}" "/tmp/gitkraken"
    install_package "/tmp/gitkraken/gitkraken-amd64.deb"
    rm -rf "/tmp/gitkraken"
    set_apt_hook gitkraken --update
}

function gitkraken_update() {
    if [[ "$(gitkraken_get_current_version)" != "$(gitkraken_get_latest_version)" ]]
    then
        gitkraken_install
    fi
}

declare -A args_map
preparse_args args_map \
    "name=install               args=no     function=gitkraken_install" \
    "name=update                args=no     function=gitkraken_update" \
    "name=current-version       args=no     function=gitkraken_get_current_version" \
    "name=latest-version        args=no     function=gitkraken_get_latest_version"
parse_args args_map n "${@}"
exec_args_flow args_map install update current-version latest-version
