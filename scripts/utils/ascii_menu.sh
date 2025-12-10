#!/bin/bash

source "${MDS_SCRIPTS}/common.sh"

function ascii_menu_add_trap() {
    trap 'printf "$NORMAL_OP"' EXIT                  ## return terminal to normal state on exit
}

function ascii_menu_print_options() {
    if [[ -n "${1}" ]]
    then
        printf "\n${1}\n"
    fi
}

function ascii_menu_show() {
    local -n menu_index_ref=${1}
    shift
    local menu_items=("${@}")
    for (( i=0; i<${#menu_ref[@]}; i+=1 ))
    do
        if (( i == menu_index_ref ))
        then
            printf "%4s ${INVERT}%s\n${BLK}" "$((i+1))." "${menu_ref[${i}]}"
        else
            printf "%4s %s\n" "$((i+1))." "${menu_ref[${i}]}"
        fi
    done
}

function ascii_menu_handle_key() {
    local -n index_ref=${1}
    local callback_func=${2:-printf ""}
    local -i menu_size=${#menu_ref[@]}

    # Read a single character
    read -s -n 1 key
    # Capture trailing characters
    read -s -N 1 -t 0.0001 k1
    read -s -N 1 -t 0.0001 k2
    read -s -N 1 -t 0.0001 k3
    key+=${k1}${k2}${k3}
    case "${key}" in
        $'\e[A'|[kK]) # Go Up
            (( (index_ref - 1) == -1 )) && index_ref=$(( menu_size ))
            index_ref=$(( (index_ref - 1) % menu_size ))
            ;;
        $'\e[B'|[jJ]) # Go Down
            index_ref=$(( (index_ref + 1) % menu_size ))
            ;;
        q|Q)
            clear
            return 1
            ;;
        *)
            ${callback_func} "${key}" "${menu_ref[${index_ref}]}"
            ;;
    esac
    return $?
}

function ascii_menu_create() {
    local title="${1}"
    local -n menu_ref=${2}
    local menu_footer=${3}
    local callback_input=${4}
    local -i menu_index=0
    clear
    while (( $? == 0 ))
    do
        printf "${TOPLEFT}${NOCURSOR}${title}\n"
        ascii_menu_show menu_index
        ascii_menu_print_options "${menu_footer}"
        ascii_menu_handle_key menu_index ${callback_input}
    done
    return 0 #Ignore #?
}
