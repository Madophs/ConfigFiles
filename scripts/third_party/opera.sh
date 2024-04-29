#!/bin/bash

source ${MDS_SCRIPTS}/common.sh
source ${MDS_SCRIPTS}/third_party/operaffmpeg.sh
PACKAGE_NAME=opera-stable
PACKAGE_VERSION=${2}
OPERA_FTP_URL=https://download5.operacdn.com/ftp/pub/opera/desktop

function do_opera_show_versions() {
    wget -qO - https://download5.operacdn.com/ftp/pub/opera/desktop/ | grep -o -e '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*' | sort -k2.2 -t '.' | uniq
}

function get_opera_download_link() {
    if [[ -z ${PACKAGE_VERSION} ]]
    then
        PACKAGE_VERSION=$(wget -qO - ${OPERA_FTP_URL} | grep -o -e '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*' | sort -k2.2 -t '.' | uniq | tail -n 1)
    else
        cout info "Using package versions: ${PACKAGE_VERSION}"
    fi

    REPO_URL=${OPERA_FTP_URL}/${PACKAGE_VERSION}/linux
    PACKAGE_FILE=$(wget -qO - ${REPO_URL} | grep -o -e '>.*<' | egrep -v 'rpm|deb\.' | grep -o -e 'opera-stable.*deb')
    echo ${REPO_URL}/${PACKAGE_FILE}
}

function do_opera_install() {
    terminate_opera_process_if_possible
    DOWNLOAD_LINK=$(get_opera_download_link)
    DOWNLOAD_DIR=/tmp/opera_tmp
    download ${DOWNLOAD_LINK} ${DOWNLOAD_DIR}
    PACKAGE_PATH=$(ls -lt ${DOWNLOAD_DIR}/opera*deb | head -n 1 | awk  '{print $NF}')
    unhold_package ${PACKAGE_NAME}
    install_package ${PACKAGE_PATH}
    hold_package ${PACKAGE_NAME}
}

function do_opera_update() {
    if [[ $(is_package_installed ${PACKAGE_NAME}) == YES ]]
    then
        terminate_opera_process_if_possible
        unhold_package ${PACKAGE_NAME}
        update_package ${PACKAGE_NAME}
        hold_package ${PACKAGE_NAME}
        return 0
    else
        cout error "${PACKAGE_NAME} is not installed."
    fi
}

function do_opera_remove() {
    sudo apt remove ${PACKAGE_NAME}
}

function do_opera_install_ffmpeg() {
    do_install_ffmpeg_with_snap
}

function do_opera_uninstall_ffmpeg() {
    do_uninstall_ffmpeg
}

OPTION=${1}
if [[ -z ${OPTION} ]]
then
    cout error "Missing options. Available install|update|remove|only-ffmpeg|with-ffmpeg|undo-ffmpeg"
fi

case ${OPTION} in
    --install)
        do_opera_install
    ;;
    --remove)
        do_opera_remove
    ;;
   --update)
        do_opera_update
        do_opera_install_ffmpeg
    ;;
   --install-with-ffmpeg)
        do_opera_install
        do_opera_install_ffmpeg
    ;;
    --only-ffmpeg)
        do_opera_install_ffmpeg
    ;;
    --undo-ffmpeg)
        do_opera_uninstall_ffmpeg
    ;;
    --versions)
        do_opera_show_versions
    ;;
    *)
        cout error "Unknown source"
    ;;
esac
