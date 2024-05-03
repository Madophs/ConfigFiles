#!/bin/sh
#/etc/bash_completion.d

_mdssetup() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [[ ${prev} == "opera" ]]
    then
        opts="--install --update --install-with-ffmpeg --undo-ffmpeg --only-ffmpeg --set-autoupdate --versions"
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi

    if [[ ${prev} == "nvim" ]]
    then
        opts="--install --setup"
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi

    if [[ ${prev} == "vifm" ]]
    then
        opts="--install --install-colorschemes"
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi

    if [[ ${prev} == "rust" ]]
    then
        opts="--install --update"
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi

    if [[ ${cur} == * ]]
    then
        opts="ACE cuda rust opera vim vifm nvim deps ckb-next"
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi

}

complete -F _mdssetup mdssetup

