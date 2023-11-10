#!/bin/bash
# By default Opera doesn't own some media codecs permissions to play some video formats on the internet
# so let's use the the codecs from Chromium that own these codecs

LIB_NAME=libffmpeg.so
DOWNLOAD_DIR='/tmp/ffmpeg'
REPO_URL='http://security.ubuntu.com/ubuntu/pool/universe/c/chromium-browser/'
TARGET_PATH=/usr/lib/x86_64-linux-gnu/opera

function exit_if_opera_running() {
    OPERA_RUNNING=$(ps -ef | awk '{print $8}' | grep -w opera)
    if [[ -n ${OPERA_RUNNING} ]]
    then
        cout warning "It seems that Opera browser is running..."
        cout warning "Please consider terminate the process before proceed."
        exit 0
    fi
}

function do_install_ffmpeg() {
    exit_if_opera_running
    if [[ -x $(which axel) ]]
    then
        mkdir -p ${DOWNLOAD_DIR}

        # Make sure there's nothing in the download directory
        sudo rm -rf ${DOWNLOAD_DIR}/*

        # Download the deb file
        PACKAGE=$(wget -qO - $REPO_URL | grep -e "\"chromium-codecs-ffmpeg-extra_[0-9].*amd64\.deb\"" -o | tail -n 1 | sed 's/"//g')
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
    exit_if_opera_running
    sudo mv -f  "${TARGET_PATH}/${LIB_NAME}.backup" $TARGET_PATH/$LIB_NAME &> /dev/null
    if [[ $(any_error $?) == "NO" ]]
    then
        cout success "ffmpeg library restored."
    else
        cout error "ffmpeg couldn't be restored"
    fi
}
