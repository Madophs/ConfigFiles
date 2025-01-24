#!/bin/sh
#/etc/bash_completion.d

_mdssetup() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    local picked_arg=${COMP_WORDS[1]}

    if [[ ${prev} == "opera" || ${picked_arg} == "opera" ]]
    then
        opts="--install --update --remove-ffmpeg --install-ffmpeg --set-autoupdate --versions --remove-set-autoupdate"
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

    if [[ ${prev} == "discord" ]]
    then
        opts="--install --update --remove --version"
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi

    if [[ ${cur} == * ]]
    then
        opts="ACE cuda rust opera vim vifm nvim deps ckb-next alias-completion discord"
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi

}

complete -F _mdssetup mdssetup

