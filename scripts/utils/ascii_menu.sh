#!/bin/bash

source "${MDS_SCRIPTS}/utils/cout.sh"

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

# @brief filter menu items
# To activate press '/' and input the filter
function ascii_menu_filter() {
    [[ "${filter_word}" == "${filter_word_prev}" ]] && return

    menu_obj=() menu_keys_obj=()
    local -i menu_size="${#menu_ref[@]}"
    local item="" item_filtered="" string_before=""
    local -i string_after_index=0
    local -l iteml="" # lowercase for easier matching
    for (( i=0; i<menu_size; i+=1))
    do
        iteml="${menu_ref[${i}]}"
        if [[ "${iteml}" == *${filter_word,,}* ]]
        then
            item="${menu_ref[${i}]}" # Get current (raw) line
            string_before="${iteml%%${filter_word,,}*}" # Substring before filter_word
            string_after_index=$(( ${#string_before} + ${#filter_word} )) # Index after filter_word
            item_filtered="${item:0:${#string_before}}${INVERT}${item:${#string_before}:${#filter_word}}${INVERT_BLK}${item:${string_after_index}}"

            # Update menu objects
            menu_obj+=( "${item_filtered}" )
            menu_keys_obj+=( "${menu_keys_ref[${i}]}" )
        fi
    done

    filter_word_prev="${filter_word}"
}

function ascii_menu_show() {
    local -n menu_index_ref=${1}
    shift
    local -i menu_size=${#menu_obj[@]}
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
            printf -v menu_line "${BLK}%4s ${UNDERLINE}%s${BLK}\n" "$((i+1))." "${menu_obj[${i}]}"
        else
            printf -v menu_line "${BLK}%4s %s${BLK}\n" "$((i+1))." "${menu_obj[${i}]}"
        fi
        printf "${menu_line}"
    done
}

function ascii_menu_handle_key() {
    local -n index_ref=${1}
    local callback_func=${2}
    local -i menu_size=${#menu_obj[@]}

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
        '/')
            read -e -i "${filter_word}" -p "Filter:" filter_word
            ;;
        q|Q)
            clear
            return 1
            ;;
        *)
            local menu_item_selected="${menu_obj[${index_ref}]}"
            local menu_item_key_selected="${menu_keys_obj[${index_ref}]}"
            [[ -n "${callback_func}" ]] && ${callback_func}
            ;;
    esac
    return $?
}

function ascii_menu_create() {
    ascii_menu_set_trap
    local -n menu_ref=${1}
    local menu_obj=( "${menu_ref[@]}" )
    local -n menu_keys_ref=${2}
    local -a menu_keys_obj=( "${menu_keys_ref[@]}" )
    local title="${3}"
    local menu_footer=${4}
    local callback_input=${5}
    local filter_word=""
    local filter_word_prev="${filter_word}"
    local -i menu_index=0
    while (( $? == 0 ))
    do
        clear

        if (( ${#menu_ref[@]} == 0 ))
        then
            cout error "No menu items provided"
        fi

        printf "${TOPLEFT}${NOCURSOR}${title}\n"
        ascii_menu_filter
        ascii_menu_show menu_index
        ascii_menu_print_options "${menu_footer}"
        [[ -n "${filter_word}" ]] && printf "Current filter: ${filter_word}\n"
        ascii_menu_handle_key menu_index ${callback_input}
    done
    return 0 #Ignore #?
}
