#!/bin/bash
# By default Opera doesn't own some media codecs permissions to play some video formats on the internet
# so let's use the the codecs from Chromium that own these codecs

LIB_NAME=libffmpeg.so
FILENAME='chromium-codecs-ffmpeg-extra_90.0.4430.93-0ubuntu0.18.04.1_amd64.deb'
LIB_URL='http://security.ubuntu.com/ubuntu/pool/universe/c/chromium-browser/'${FILENAME}
DOWNLOAD_DIR='/tmp/ffmpeg'
TARGET_PATH=/usr/lib/x86_64-linux-gnu/opera

# Check if the lib exists

if [[ -x $(which axel) ]]
then
    mkdir -p ${DOWNLOAD_DIR}
    echo $LIB_URL
    axel --alternate --output=${DOWNLOAD_DIR} ${LIB_URL}
    if [[ $? == 0 ]]
    then
        if [[ -d $TARGET_PATH ]]
        then
            echo "Root privileges required!"

            pushd ${DOWNLOAD_DIR}
            ar x ${FILENAME} data.tar.xz
            sudo tar -xJf data.tar.xz --strip-components=4 && sudo cp -f $LIB_NAME $TARGET_PATH

            RET=$?

            if [[ ${RET} == 0 ]]
            then
                echo "Library replacement was performed successfully"
            else
                echo "[ERROR] unknown."
            fi

            popd
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
