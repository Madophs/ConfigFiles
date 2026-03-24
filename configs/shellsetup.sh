#!/bin/env bash

# necessary files and directories
mkdir -p "${MDS_HIDDEN_CONFIGS}"
mkdir -p "${MDS_SESSIONS_DIR}"
touch "${MDS_TRAP_CMD}"
touch "${MDS_ROOT_FILE}"

if [[ ! -h "${HOME}/.local/bin/mdssetup" ]]
then
    mkdir -p ~/.local/bin
    ln -s -T "${MDS_SCRIPTS}/mdssetup.sh" ~/.local/bin/mdssetup
fi

if [[ ! -h /etc/bash_completion.d/mdscode-prompt && -f "${GIT_REPOS}/MdsCode_Bash/src/mds-prompt" ]]
then
    sudo ln -s -T "${GIT_REPOS}/MdsCode_Bash/src/mds-prompt" /etc/bash_completion.d/mdscode-prompt
fi

if [[ -f /usr/share/autojump/autojump.bash ]]
then
    source /usr/share/autojump/autojump.bash
fi

# User VI like map keys
set -o vi

# Disable error when overriding a file
set +o noclobber

if [[ "${REAL_SHELL}" == "zsh" ]]
then
    source "${MDS_CONFIG}/configs/zsh/zshrc.sh"
else
    source "${MDS_CONFIG}/configs/bash/bashrc.sh"
fi

source "${MDS_CONFIG}/configs/aliases.sh"
source "${MDS_CONFIG}/configs/autocomplete.sh"

