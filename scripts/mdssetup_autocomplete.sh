#!/bin/sh
#/etc/bash_completion.d

_mdssetup() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    local -a __hook_scripts=( $(ls "${MDS_SCRIPTS}/third_party/"*.sh) )
    __hook_scripts=( ${__hook_scripts[@]#*party/} )

    local hook_script
    for hook_script in ${__hook_scripts[@]}
    do
        [[ ${prev} != "${hook_script}" ]] && continue
        local -a shell_params=( $(grep '#shellparams' "${MDS_SCRIPTS}/third_party/${hook_script}" 2> /dev/null) )
        shell_params=( "${shell_params[@]%#shellparams}" )
        opts="${shell_params[@]}"
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    done

    if [[ ${prev} == "add_hook" ]]
    then
        opts="${__hook_scripts[@]}"
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi

    if [[ ${prev} == "remove_hook" ]]
    then
        opts="$(cat "${MDS_HIDDEN_CONFIGS}/apt_hooks" 2> /dev/null)"
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi

    if [[ ${cur} == * ]]
    then
        opts="list_hooks add_hook remove_hook remove_all_hooks autocomplete ${__hook_scripts[@]}"
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi
}

complete -F _mdssetup mdssetup
