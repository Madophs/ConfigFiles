#!/bin/bash

# This scripts setup/install some 3rd party software that I personally use.

if [[ $# != 1 ]]
then
    echo "Usage: mdsetup [program]"
    echo "Jehú Jair Ruiz Villegas"
    exit 0
fi

SUBJECT=$1
SOURCE_PATH=$MDS_SCRIPTS/third_party

case $SUBJECT in
    ACE)
        $SOURCE_PATH/ACE.sh
    ;;
    *)
        echo "[ERROR]Unknown source"
        exit 1
    ;;
esac
