#!/bin/bash
# By default Opera doesn't own some media codecs permissions to play some video formats on the internet
# so let's use the the codecs from Chromium that own these codecs

LIB_NAME=libffmpeg.so
FFMPEG_PACKAGE=chromium-ffmpeg
FFMPEG_PACKAGE_DIR=${FFMPEG_DEFAULT_PACKAGE_DIR:-'/snap/chromium-ffmpeg/current'}
DOWNLOAD_DIR='/tmp/ffmpeg'
REPO_URL='http://security.ubuntu.com/ubuntu/pool/universe/c/chromium-browser/'
REPO_ALT_URL='https://github.com/Ld-Hagen/fix-opera-linux-ffmpeg-widevine/releases/latest'
TARGET_PATH=$(readlink -f $(which opera) | grep -o -e '^/.\+/' | sed 's|/$|/lib_extra|g')

sudo mkdir -p ${TARGET_PATH}

function terminate_opera_process_if_possible() {
    opera_pid=$(ps -ef | grep -e 'opera$' | grep -v grep | awk '{print $2}')
    if [[ -n ${opera_pid} ]]
    then
        kill -s TERM ${opera_pid}
        opera_pid=$(ps -ef | grep -e 'opera$' | grep -v grep | awk '{print $2}')
        local timeout_cnt=3
        while [[ -n ${opera_pid} ]]
        do
            if [[ ${timeout_cnt} == 0 ]]
            then
                cout warning "It seems that Opera browser is running..."
                cout warning "Please consider terminate the process before proceed."
                exit 1
            fi
            sleep 1
            timeout_cnt=$(( timeout_cnt - 1 ))
            opera_pid=$(ps -ef | grep -e 'opera$' | grep -v grep | awk '{print $2}')
        done
    fi
}

function do_install_ffmpeg_alt() {
    local latest_release=$(wget --max-redirect 0 ${REPO_ALT_URL} 2>&1 | grep Location | grep -o 'https:.\+[0-9]')
    local latest_version=$(echo ${latest_release} | grep -o -e '[0-9]\+\.[0-9]\+\.[0-9]\+$')
    local filename="${latest_version}-linux-x64.zip"
    local download_link=$(echo ${latest_release} | sed 's|/tag/|/download/|g')/${filename}
    local download_tmp_dir='/tmp/tmp_ffmpeg'
    mkdir -p ${download_tmp_dir}
    download ${download_link} ${download_tmp_dir}
    sudo unzip -o ${download_tmp_dir}/${filename} -d ${TARGET_PATH}
}

function set_ffmpeg_library_path() {
    if [[ ${FFMPEG_PACKAGE_DIR} == '/snap/chromium-ffmpeg/current' ]]
    then
        LAST_DIR=$(ls -lt ${FFMPEG_PACKAGE_DIR}/${FFMPEG_PACKAGE}* | head -n 1 | awk -F '[/]' '{print $NF}'| sed s/://g)
        FFMPEG_LIBRARY_PATH=${FFMPEG_PACKAGE_DIR}/${LAST_DIR}/${FFMPEG_PACKAGE}/${LIB_NAME}
    else
        FFMPEG_LIBRARY_PATH=${FFMPEG_PACKAGE_DIR}
    fi
}

function do_install_ffmpeg_with_snap() {
    install_package_with_snap ${FFMPEG_PACKAGE}
    sudo cp ${TARGET_PATH}/${LIB_NAME} ${TARGET_PATH}/${LIB_NAME}.backup
    set_ffmpeg_library_path
    sudo cp -f ${FFMPEG_LIBRARY_PATH} ${TARGET_PATH}
    if [[ $(any_error $?) == "YES" ]]
    then
        cout error "something went wrong"
    fi
}

function do_install_ffmpeg() {
    terminate_opera_process_if_possible
    if [[ -x $(which axel) ]]
    then
        mkdir -p ${DOWNLOAD_DIR}

        # Make sure there's nothing in the download directory
        sudo rm -rf ${DOWNLOAD_DIR}/*

        # Download the deb file
        PACKAGE=$(wget -qO - ${REPO_URL} | grep -e "\"chromium-codecs-ffmpeg-extra_[0-9].*amd64\.deb\"" -o | tail -n 1 | sed 's/"//g')
        DOWNLOAD_LINK=${REPO_URL}${PACKAGE}
        download ${DOWNLOAD_LINK} ${DOWNLOAD_DIR}

        if [[ $(any_error $?) == "NO" ]]
        then
            if [[ -d $TARGET_PATH ]]
            then

                pushd ${DOWNLOAD_DIR} &> /dev/null
                ls -f *deb | xargs ar x

                cout warning "Root privileges required!"
                sudo cp -f $TARGET_PATH/$LIB_NAME "${TARGET_PATH}/${LIB_NAME}.backup"
                sudo tar -xJf data.tar.xz --strip-components=4 && sudo cp -f $LIB_NAME $TARGET_PATH

                RET=$?
                if [[ $(any_error ${RET}) == "NO" ]]
                then
                    cout success "Library replacement was performed successfully"
                else
                    cout error "Unknown."
                fi

                popd &> /dev/null
                exit ${RET}
            else
                cout error "Target path [${TARGET_PATH}] doesn't exists"
            fi
        else
            cout error "An error occcured while trying to download the file."
        fi
    else
        cout error "axel bin not found, please consider install it."
    fi
}

function do_uninstall_ffmpeg() {
    terminate_opera_process_if_possible
    sudo mv -f  "${TARGET_PATH}/${LIB_NAME}.backup" $TARGET_PATH/$LIB_NAME &> /dev/null
    if [[ $(any_error $?) == "NO" ]]
    then
        cout success "ffmpeg library restored."
    else
        cout error "ffmpeg couldn't be restored"
    fi
}

