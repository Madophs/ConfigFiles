#!/bin/bash
. ${MDS_SCRIPTS}/common.sh

function vifm_install_colorschemes() {
    TARGET_DIRECTORY=${HOME}/.config/vifm/colors
    rm -rf ${TARGET_DIRECTORY} &> /dev/null
    git clone https://github.com/vifm/vifm-colors ~/.config/vifm/colors
    if [[ $(any_error $?) == "NO" ]]
    then
        cout success "Colorschemes installed"
    else
        cout error "Failed to install"
    fi
}

function get_vifm_source_code_link() {
    TAGS_LINK=https://github.com/vifm/vifm/tags
    SUFFIX_LINK=$(curl -Ls ${TAGS_LINK} | grep -o -e '\/vifm/vifm/.*v[0-9]*\.[0-9]*\.tar.gz' | head -n 1)
    echo "https://github.com${SUFFIX_LINK}"
}

function vifm_download_source_code() {
    DOWNLOAD_DIR=/tmp/vifm
    mkdir -p ${DOWNLOAD_DIR}
    rm -rf ${DOWNLOAD_DIR}/* &> /dev/null
    download ${SOURCE_CODE_LINK} ${DOWNLOAD_DIR}
}

function vifm_install() {
    set -e
    SOURCE_CODE_LINK=$(get_vifm_source_code_link)
    if [[ -z ${SOURCE_CODE_LINK} ]]
    then
        cout error "Failed to get source code"
    fi

    vifm_download_source_code
    tar -xf $(ls ${DOWNLOAD_DIR}/*tar.gz) -C ${DOWNLOAD_DIR}
    SOURCE_CODE_DIR=$(ls -d ${DOWNLOAD_DIR}/*/)
    pushd ${SOURCE_CODE_DIR} &> /dev/null

    cout info "About to compile vifm"
    sleep 3
    ./configure
    make

    cout info "About to install vifm"
    sleep 3
    sudo make install ; RET=$?
    popd &> /dev/null

    if [[ $(any_error ${RET}) == "NO" ]]
    then
        cout success "vifm installed"
    else
        cout error "Failed to install vifm"
    fi
}

OPTION=$1
case ${OPTION} in
    --install)
        vifm_install
    ;;
    --install-colorschemes)
        vifm_install_colorschemes
    ;;
    *)
        cout error "Invalid option"
    ;;
esac

