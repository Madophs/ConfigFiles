#!/usr/bin/env bash

source ${MDS_SCRIPTS}/common.sh
source ${MDS_SCRIPTS}/autocomplete.sh

mkdir -p ${MDS_HIDDEN_CONFIGS}
mkdir -p ${MDS_SESSIONS_DIR}

if [[ ! -f  ${MDS_ROOT_FILE} ]]
then
    touch ${MDS_ROOT_FILE}
fi

# Symbolic links
if [[ ! -h ~/.local/bin/mdssetup ]]
then
    mkdir -p ~/.local/bin
    ln -s -T ${MDS_SCRIPTS}/mdssetup.sh ~/.local/bin/mdssetup
fi

if [[ ! -h /etc/bash_completion.d/mdscode-prompt && -f ${GIT_REPOS}/MdsCode_Bash/src/mds-prompt ]]
then
    cout info "Setting up mdscode prompt"
    sudo ln -s -T ${GIT_REPOS}/MdsCode_Bash/src/mds-prompt /etc/bash_completion.d/mdscode-prompt
fi

# Let's ignore some common commands of being registered from history
zshaddhistory() {
    # Get the command the remove the carriage return
    INPUT_COMMAND=${1%$'\n'}
    case ${INPUT_COMMAND} in
        ls|ls\ *|ll|ls\ *)
            return 1
            ;;
        clear)
            return 1
            ;;
        cd)
            return 1
            ;;
        loadsh|setroot)
            return 1;
    esac
    return 0;
}
