#!/bin/bash

source "${MDS_SCRIPTS}/common.sh"

declare -g IS_TRAPED_SETUP=N

function ascii_menu_set_trap() {
    if [[ "${IS_TRAPED_SETUP}" == N ]]
    then
        trap 'printf "$NORMAL_OP"' EXIT                  ## return terminal to normal state (reset cursor's visibility and position) on exit
    fi
    IS_TRAPED_SETUP=Y
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
    local -i menu_size=${#menu_ref[@]}
    local -i window_size=$(( LINES - 4 )) # tty height
    local -i menu_scroll_size=menu_size

    # If items outsize scroll view, set scroll view to shell height (window_size)
    (( menu_scroll_size > window_size )) && menu_scroll_size=window_size

    local -i menu_item_index_start=0
    local -i menu_item_index_end=menu_size

    # upper/lower item padding
    local -i menu_scroll_slice=$(( menu_scroll_size / 2 ))

    # update start index if position is beyond scroll slice (upper bound)
    (( menu_index_ref - menu_scroll_slice > 0 )) && menu_item_index_start=$(( menu_index_ref - menu_scroll_slice ))

    menu_item_index_end=$(( menu_item_index_start + menu_scroll_size ))

    # Print all possible items above index in case we're near end of the list
    (( menu_item_index_end > menu_size )) && menu_item_index_start=$(( menu_size - menu_scroll_size ))

    for (( i=menu_item_index_start; i<menu_item_index_end && i<menu_size; i+=1 ))
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
    local callback_func=${2}
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
            local menu_item_selected="${menu_ref[${index_ref}]}"
            [[ -n "${callback_func}" ]] && ${callback_func}
            ;;
    esac
    return $?
}

function ascii_menu_create() {
    ascii_menu_set_trap
    local title="${1}"
    local -n menu_ref=${2}
    local menu_footer=${3}
    local callback_input=${4}
    local -i menu_index=0
    while (( $? == 0 ))
    do
        clear
        printf "${TOPLEFT}${NOCURSOR}${title}\n"
        ascii_menu_show menu_index
        ascii_menu_print_options "${menu_footer}"
        ascii_menu_handle_key menu_index ${callback_input}
    done
    return 0 #Ignore #?
}
