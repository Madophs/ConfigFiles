#!/usr/bin/env bash

trap 'eval "$(< "${MDS_TRAP_CMD}")"; truncate -s 0 "${MDS_TRAP_CMD}"' SIGUSR1

HISTSIZE=7000
HISTFILESIZE=7000
export HISTCONTROL='erasedups:ignoreboth'
unset -v HISTTIMEFORMAT  # %F %T

shopt -s autocd
shopt -s cdable_vars
shopt -s extglob
shopt -s histappend
shopt -s nocaseglob
shopt -s nocasematch
shopt -s nullglob
bind 'set show-all-if-ambiguous on'
bind -s 'set completion-ignore-case on'
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

if [[ -f "${GIT_REPOS}/Bash-Complete-Menu/bash_complete_menu.sh" ]]
then
    source "${GIT_REPOS}/Bash-Complete-Menu/bash_complete_menu.sh"
    bind -x '"\C-i":bash_complete_menu'
else
    bind 'TAB:complete'
fi

if [[ ! -h "${HOME}/.inputrc" ]]
then
    rm -f "${HOME}/.inputrc"
    ln -s "${MDS_CONFIG}/configs/bash/inputrc" "${HOME}/.inputrc"
fi

source "${MDS_CONFIG}/scripts/utils/clock_timer.sh"

# export functions
export -f cout
export -f print_stacktrace
export -f export_colors
export -f unset_colors
export -f clock_start
export -f clock_end

# calling functions
export_colors
