#!/bin/bash

SOURCE_PATH=${MDS_SCRIPTS}/third_party
source ${MDS_SCRIPTS}/common.sh


# This scripts setup/install some 3rd party software that I personally use.
if [[ $# < 1 ]]
then
    echo "Usage: mdsetup [program] [options]..."
    echo 'Run "mdssetup autocomplete" for bash autocompletion'
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
    rust)
        ${SOURCE_PATH}/rust.sh $@
    ;;
    nvim)
        shift
        ${SOURCE_PATH}/nvim.sh $@
    ;;
    vim)
        ${SOURCE_PATH}/vim.sh
    ;;
    vifm)
        shift
        ${SOURCE_PATH}/vifm.sh $@
    ;;
    opera)
        shift
        ${SOURCE_PATH}/opera.sh $@
    ;;
    ckb-next)
        ${SOURCE_PATH}/ckb_next.sh
    ;;
    autocomplete)
        sudo ln -s ${MDS_SCRIPTS}/mdssetup_autocomplete.sh /etc/bash_completion.d/mdssetup-prompt
    ;;
    deps)
        ${SOURCE_PATH}/deps.sh
    ;;
    alias-completion)
        ${SOURCE_PATH}/alias_completion.sh
    ;;
    *)
        cout error "Unknown option."
    ;;
esac
