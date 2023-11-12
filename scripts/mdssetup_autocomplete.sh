#!/bin/sh
#/etc/bash_completion.d

_mdssetup() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [[ ${prev} == "opera" ]]
    then
        opts="--install --update --with-ffmpeg --undo-ffmpeg --only-ffmpeg"
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi

    if [[ ${prev} == "vifm" ]]
    then
        opts="--install-colorschemes"
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi

    if [[ ${cur} == * ]]
    then
        opts="ACE cuda opera vim vifm nvim"
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi

}

complete -F _mdssetup mdssetup

