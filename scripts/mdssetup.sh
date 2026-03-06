#!/bin/bash

SOURCE_PATH=${MDS_SCRIPTS}/third_party
source ${MDS_SCRIPTS}/common.sh

declare -g APT_HOOKS_FILE="${MDS_HIDDEN_CONFIGS}/apt_hooks"
declare -g -a hook_scripts=( $(ls "${SOURCE_PATH}/"*.sh) )
hook_scripts=(${hook_scripts[@]#*party/})

function add_hook() {
    missing_argument_validation 1 ${1}
    local hook_new=${1}
    local -i is_hook_duplicated=0
    local -a apt_hooks=()
    if mapfile -t apt_hooks < "${APT_HOOKS_FILE}" 2> /dev/null;
    then
        for apt_hook in ${apt_hooks[@]}
        do
            if [[ "${hook_new}" == "${apt_hook}" ]]
            then
                is_hook_duplicated=1
                break
            fi
        done
    fi

    if (( ! is_hook_duplicated ))
    then
        echo "${hook_new}" >> "${APT_HOOKS_FILE}"
    fi
}

function remove_hook() {
    missing_argument_validation 1 ${1}
    local hook_del=${1}
    local -a apt_hooks=()
    if mapfile -t apt_hooks < "${APT_HOOKS_FILE}" 2> /dev/null;
    then
        printf "%s\n" ${apt_hooks[@]%${hook_del}} > "${APT_HOOKS_FILE}"
        return
    fi
}

# This scripts setup/install some 3rd party software that I personally use.
if [[ $# < 1 ]]
then
    echo "Usage: mdsetup [program] [options]..."
    echo 'Run "mdssetup autocomplete" for bash autocompletion'
    echo "Jehú Jair Ruiz Villegas"
    exit 0
fi

SUBJECT=${1}
case ${SUBJECT} in
    add_hook)
        shift
        add_hook $@
        ;;
    remove_hook)
        shift
        remove_hook $@
        ;;
    remove_all_hooks)
        truncate --size 0 "${APT_HOOKS_FILE}" &> /dev/null
        ;;
    list_hooks)
        cat "${APT_HOOKS_FILE}" 2> /dev/null
        ;;
    autocomplete)
        sudo ln -s ${MDS_SCRIPTS}/mdssetup_autocomplete.sh /etc/bash_completion.d/mdssetup-prompt
    	;;
    *)
        shift
        for script in ${hook_scripts[@]}
        do
            [[ "${script}" == "${SUBJECT}" ]] && ${SOURCE_PATH}/${SUBJECT} ${@} && exit 0
        done
        cout error "Unknown option «${@}»"
    	;;
esac
