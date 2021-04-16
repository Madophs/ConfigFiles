#!/bin/bash
# By default Opera doesn't own some media codecs permissions to play some video formats on the internet
# so let's use the the codecs from 'Skype for linux' that own this codecs

LIB_NAME=libffmpeg.so
LIB_PATH=/usr/share/skypeforlinux/
LIB_FULLPATH=/usr/share/skypeforlinux/$LIB_NAME
TARGET_PATH=/usr/lib/x86_64-linux-gnu/opera/

# Check if the lib exists
if [[ -f $LIB_FULLPATH ]]; then
    if [[ -d $TARGET_PATH ]]; then
        echo "Root privileges required!"
        sudo cp -f $LIB_FULLPATH $TARGET_PATH
        echo "Library replacement was performed successfully"
    else
        echo "Error: target path [$TARGET_PATH] doesn't exists"
    fi
else
    echo "Error: library [$LIB_NAME] not found in path [$LIB_PATH]"
fi
