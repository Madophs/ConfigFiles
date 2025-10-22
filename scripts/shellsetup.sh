#!/usr/bin/env bash

# Shell configurations
HISTSIZE=3000
HISTFILESIZE=3000

# User VI like map keys
set -o vi

# Disable error when overriding a file
set +o noclobber

# trap to execute any command
trap "eval \"\$(< ${MDS_TRAP_CMD})\"; truncate -s 0 ${MDS_TRAP_CMD}" 35

if [[ ${REAL_SHELL} == 'bash' ]]
then
    set show-all-if-ambiguous on
    bind 'set completion-ignore-case on'
    bind 'TAB:menu-complete'
    bind '"\e[A": history-search-backward'
    bind '"\e[B": history-search-forward'
    bind 'set show-mode-in-prompt on'
    bind 'set vi-ins-mode-string "\e[1;35mI\e[0;0m"'
    bind 'set vi-cmd-mode-string "\e[1;35mC\e[0;0m"'
    export HISTCONTROL='erasedups:ignoreboth'
    unset -v HISTTIMEFORMAT  # %F %T
fi

source ${MDS_SCRIPTS}/common.sh
source ${MDS_SCRIPTS}/autocomplete.sh

mkdir -p ${MDS_HIDDEN_CONFIGS}
mkdir -p ${MDS_SESSIONS_DIR}

touch ${MDS_TRAP_CMD}

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

if [[ -f /usr/share/autojump/autojump.bash ]]
then
    source /usr/share/autojump/autojump.bash
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
