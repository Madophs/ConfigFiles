#!/bin/sh
#/etc/bash_completion.d

_mdssetup_read() {
    if [[ $REAL_SHELL == "bash" ]]
    then
        compgen -V COMPREPLY -W "${1}" -- "${2}"
    else
        read -r -d '' -A COMPREPLY <<< "$(compgen -W "${1}" -- "${2}")"
    fi
}

_mdssetup() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts=""

    local -a __setup_scripts=("${MDS_SCRIPTS}/setups/"*.sh)
    __setup_scripts=( "${__setup_scripts[@]##*setups/}" )

    local setup_script
    for setup_script in "${__setup_scripts[@]}"
    do
        [[ ${prev} != "${setup_script}" ]] && continue

        # open file on different FD
        exec 3< "${MDS_SCRIPTS}/setups/${setup_script}"
        # Skip the shebang line
        read -r <&3
        while true;
        do
            read -r var <&3
            [[ "${var:0:12}" != "#shellparams" ]] && break
            opts+="${var:13} "
        done
        # close FD
        exec 3<&-

        _mdssetup_read "${opts}" "${cur}"
        return 0
    done

    if [[ ${prev} == "add_hook" ]]
    then
        opts="${__setup_scripts[*]}"
        _mdssetup_read "${opts}" "${cur}"
        return 0
    fi

    if [[ ${prev} == "remove_hook" ]]
    then
        opts="$(cat "${MDS_HIDDEN_CONFIGS}/apt_hooks" 2> /dev/null)"
        _mdssetup_read "${opts}" "${cur}"
        return 0
    fi

    if [[ ${cur} == * ]]
    then
        opts="list_hooks add_hook remove_hook remove_all_hooks autocomplete ${__setup_scripts[*]}"
        _mdssetup_read "${opts}" "${cur}"
        return 0
    fi
}

complete -F _mdssetup mdssetup
