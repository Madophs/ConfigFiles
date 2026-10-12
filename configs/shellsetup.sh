#!/bin/env bash

# necessary files and directories
mkdir -p "${MDS_HIDDEN_CONFIGS}"
mkdir -p "${MDS_SESSIONS_DIR}"
mkdir -p "${MDS_VOCAB_DIR}"
mkdir -p "${MDS_APPS}"
mkdir -p "${GIT_REPOS}"
touch "${MDS_TRAP_CMD}"
touch "${MDS_ROOT_FILE}"

if [[ ! -h "${HOME}/.local/bin/mdssetup" || ! -e ${HOME}/.local/bin/mdssetup ]]
then
    mkdir -p ~/.local/bin
    unlink "${HOME}/.local/bin/mdssetup" &> /dev/null
    ln -s -T "${MDS_SCRIPTS}/mdssetup.sh" ~/.local/bin/mdssetup
fi

if [[ -f "${GIT_REPOS}/MdsCode_Bash/src/mds-prompt"
      && ( ! -h /etc/bash_completion.d/mdscode-prompt || ! -e "/etc/bash_completion.d/mdscode-prompt" ) ]]
then
    sudo unlink /etc/bash_completion.d/mdscode-prompt &> /dev/null
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

