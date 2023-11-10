#!/bin/bash

SOURCE_PATH=${MDS_SCRIPTS}/third_party
source ${MDS_SCRIPTS}/common.sh

# This scripts setup/install some 3rd party software that I personally use.
if [[ $# < 1 ]]
then
    echo "Usage: mdsetup [program] [options]..."
    echo "Jehú Jair Ruiz Villegas"
    exit 0
fi

SUBJECT=$1
case ${SUBJECT} in
    ACE)
        ${SOURCE_PATH}/ACE.sh
    ;;
    cuda)
        ${SOURCE_PATH}/cuda.sh
    ;;
    nvim)
        ${SOURCE_PATH}/nvim.sh
    ;;
    vim)
        ${SOURCE_PATH}/vim.sh
    ;;
    opera)
        shift
        ${SOURCE_PATH}/opera.sh $@
    ;;
    autocomplete)
        sudo ln -s ${MDS_SCRIPTS}/mdssetup_autocomplete.sh /etc/bash_completion.d/mdssetup-prompt
    ;;
    *)
        cout error "Unknown option."
    ;;
esac
