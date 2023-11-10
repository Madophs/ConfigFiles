#!/bin/bash

source ${MDS_SCRIPTS}/common.sh
PACKAGE_NAME=opera-stable

function get_opera_download_link() {
    FTP_URL=https://download5.operacdn.com/ftp/pub/opera/desktop
    VERSION=$(wget -qO - ${FTP_URL} | grep -o -e '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*' | sort -k2.2 -t '.' | uniq | tail -n 1)
    REPO_URL=${FTP_URL}/${VERSION}/linux
    PACKAGE_VERSION=$(wget -qO - ${REPO_URL} | grep -o -e '>.*<' | egrep -v 'rpm|deb\.' | grep -o -e 'opera-stable.*deb')
    echo ${REPO_URL}/${PACKAGE_VERSION}
}

function do_opera_install() {
    DOWNLOAD_LINK=$(get_opera_download_link)
    DOWNLOAD_DIR=/tmp/opera_tmp
    download ${DOWNLOAD_LINK} ${DOWNLOAD_DIR}
    PACKAGE_PATH=$(ls -lt ${DOWNLOAD_DIR}/opera*deb | head -n 1 | awk  '{print $NF}')
    unhold_package ${PACKAGE_NAME}
    install_package ${PACKAGE_PATH}
    hold_package ${PACKAGE_NAME}
}

function do_opera_remove() {
    sudo apt remove ${PACKAGE_NAME}
}

function do_opera_install_ffmpeg() {
    source ${MDS_SCRIPTS}/third_party/operaffmpeg.sh
    do_install_ffmpeg
}

function do_opera_uninstall_ffmpeg() {
    source ${MDS_SCRIPTS}/third_party/operaffmpeg.sh
    do_uninstall_ffmpeg
}

OPTION=$1
if [[ -z ${OPTION} ]]
then
    cout error "Missing options. Available install|update|remove|only-ffmpeg|with-ffmpeg|undo-ffmpeg"
fi

case ${OPTION} in
    --install|--update)
        do_opera_install
    ;;
    --remove)
        do_opera_remove
    ;;
    --with-ffmpeg)
        do_opera_install
        do_opera_install_ffmpeg
    ;;
    --only-ffmpeg)
        do_opera_install_ffmpeg
    ;;
    --undo-ffmpeg)
        do_opera_uninstall_ffmpeg
    ;;
    *)
        cout error "Unknown source"
    ;;
esac
