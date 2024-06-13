#!/bin/bash

source ${MDS_SCRIPTS}/common.sh
source ${MDS_SCRIPTS}/third_party/operaffmpeg.sh
PACKAGE_NAME=opera-stable
PACKAGE_VERSION=${2}
OPERA_FTP_URL=https://download5.operacdn.com/ftp/pub/opera/desktop

function do_opera_show_versions() {
    wget -qO - ${OPERA_FTP_URL} | grep -E '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*' | \
        sed -e 's|<.*">||g' -e 's|/<.*a>||g' | awk '{print $1" "$2}' | sort -k2.2 -t '.' | uniq | tail -n 20

    cout info "Current version: " $(opera --version)
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

function do_set_autoupdate() {
    local apt_opera_autofix='/etc/apt/apt.conf.d/99fix-opera'
    sudo touch ${apt_opera_autofix}
    sudo truncate -s 0 ${apt_opera_autofix}
    echo 'DPkg::Pre-Invoke {"stat -c %Z $(readlink -f $(which opera)) > /tmp/opera.timestamp";};' | sudo tee -a ${apt_opera_autofix}
    echo 'DPkg::Post-Invoke {"if [ `stat -c %Z $(readlink -f $(which opera))` -ne `cat /tmp/opera.timestamp` ]; then export MDS_SCRIPTS={{}};${MDS_SCRIPTS}/third_party/opera.sh --only-ffmpeg; fi; rm /tmp/opera.timestamp";};' | sed "s|{{}}|${MDS_SCRIPTS}|g"| sudo tee -a ${apt_opera_autofix}
}

function do_opera_remove() {
    sudo apt remove ${PACKAGE_NAME}
}

function do_opera_install_ffmpeg() {
    terminate_opera_process_if_possible
    do_install_ffmpeg_alt
    cout success "libffmpeg library installed"

    local ppid=$(ps -o ppid $$ | tail -n 1 | awk '{print $NF}')
    local ppid_command=$(ps -o command ${ppid} | tail -n 1)
    if [[ ${ppid_command:0:8} == "sh -c --" ]]
    then
        cout warning "You may start opera manually after system upgrade..."
        sleep 2
    else
        cout info "starting opera..."
        sleep 2
        opera &> /dev/null &
    fi
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
    --set-autoupdate)
        do_set_autoupdate
    ;;
    --versions)
        do_opera_show_versions
    ;;
    *)
        cout error "Unknown source"
    ;;
esac
