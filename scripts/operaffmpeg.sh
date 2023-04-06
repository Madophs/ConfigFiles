#!/bin/bash
# By default Opera doesn't own some media codecs permissions to play some video formats on the internet
# so let's use the the codecs from Chromium that own these codecs

LIB_NAME=libffmpeg.so
DOWNLOAD_DIR='/tmp/ffmpeg'
REPO_URL='http://security.ubuntu.com/ubuntu/pool/universe/c/chromium-browser/'
TARGET_PATH=/usr/lib/x86_64-linux-gnu/opera

# Check if the lib exists

OPERA_RUNNING=$(ps -ef | grep -w opera | grep -v grep)

if [[ -n ${OPERA_RUNNING} ]]
then
    echo "It seems that Opera browser is running..."
    echo "Please consider terminate the process before proceed."
    exit 0
fi

if [[ -x $(which axel) ]]
then
    mkdir -p ${DOWNLOAD_DIR}

    # Make sure there's nothing in the download directory
    sudo rm -rf ${DOWNLOAD_DIR}/*

    # Download the deb file
    PACKAGE=$(wget -qO - $REPO_URL | grep -e "\"chromium-codecs-ffmpeg-extra_[0-9].*amd64\.deb\"" -o | tail -n 1 | sed 's/"//g')
    DOWNLOAD_LINK=${REPO_URL}${PACKAGE}
    axel --alternate --output=${DOWNLOAD_DIR} ${DOWNLOAD_LINK}

    if [[ $? == 0 ]]
    then
        if [[ -d $TARGET_PATH ]]
        then

            pushd ${DOWNLOAD_DIR} &> /dev/null
            ls -f *deb | xargs ar x

            echo "Root privileges required!"
            sudo cp -f $TARGET_PATH/$LIB_NAME "${TARGET_PATH}/${LIB_NAME}.backup"
            sudo tar -xJf data.tar.xz --strip-components=4 && sudo cp -f $LIB_NAME $TARGET_PATH

            RET=$?

            if [[ ${RET} == 0 ]]
            then
                echo "Library replacement was performed successfully"
            else
                echo "[ERROR] unknown."
            fi

            popd &> /dev/null
            exit $RET
        else
            echo "Error: target path [$TARGET_PATH] doesn't exists"
        fi
    else
        echo "[ERROR] An error occcured while trying to download the file."
    fi
else
    echo "[ERROR] axel bin not found, please consider install it."
fi
