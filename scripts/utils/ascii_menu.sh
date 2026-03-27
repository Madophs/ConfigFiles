#!/bin/bash

source "${MDS_SCRIPTS}/utils/cout.sh"

declare -g IS_TRAPED_SETUP=N

function ascii_menu_set_trap() {
    stty -echo # Disable echoing (typing output)
    if [[ "${IS_TRAPED_SETUP}" == N ]]
    then
        trap 'printf "$NORMAL_OP"; stty echo' EXIT # return terminal to normal state (reset cursor's visibility and position) on exit
    fi
    IS_TRAPED_SETUP=Y
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
            string_before="${iteml%%"${filter_word,,}"*}" # Substring before filter_word
            string_after_index=$(( ${#string_before} + ${#filter_word} )) # Index after filter_word
            item_filtered="${item:0:${#string_before}}${INVERT}${item:${#string_before}:${#filter_word}}${INVERT_BLK}${item:${string_after_index}}"

            # Update menu objects
            menu_obj+=( "${item_filtered}" )
            menu_keys_obj+=( "${menu_keys_ref[${i}]}" )
        fi
    done

    filter_word_prev="${filter_word}"
    menu_index=0
    menu_item_start_index_prev=-1
}

function ascii_menu_show() {
    local -i menu_size=${#menu_obj[@]}
    local -i window_size=$(( LINES - 5 )) # tty height
    local -i menu_scroll_size=menu_size

    # If items outsize scroll view, set scroll view to shell height (window_size)
    (( menu_scroll_size > window_size )) && menu_scroll_size=window_size

    local -i menu_item_start_index=0
    local -i menu_item_end_index=menu_size

    # upper/lower item padding
    local -i menu_scroll_slice=$(( menu_scroll_size / 2 ))

    # update start index if position is beyond scroll slice (upper bound)
    (( menu_index - menu_scroll_slice > 0 )) && menu_item_start_index=$(( menu_index - menu_scroll_slice ))

    menu_item_end_index=$(( menu_item_start_index + menu_scroll_size ))

    # Print all possible items above index in case we're near the list's end (bottom)
    (( menu_item_end_index > menu_size )) && menu_item_start_index=$(( menu_size - menu_scroll_size ))

    local -i line_number=0
    # if start index has changed implies that we are scrolling, then we have to repaint every menu item
    if (( menu_item_start_index_prev != menu_item_start_index ))
    then
        for (( i=menu_item_start_index; i<menu_item_end_index && i<menu_size; i+=1 ))
        do
            if (( i == menu_index ))
            then
                printf "${CLEAR_LINE}${BLK}%5s ${UNDERLINE}${menu_obj[${i}]}${BLK}\n" "$((i+1))."
            else
                printf "${CLEAR_LINE}${BLK}%5s ${menu_obj[${i}]}${BLK}\n" "$((i+1))."
            fi
        done
    else
        line_number=$(( (menu_index_prev + 2 - menu_item_start_index) % (menu_scroll_size + 2)))
        printf "\e[${line_number};0H${CLEAR_LINE}${BLK}%5s ${menu_obj[${menu_index_prev}]}${BLK}" "$((menu_index_prev+1))."

        line_number=$(( (menu_index + 2 - menu_item_start_index) % (menu_scroll_size + 2)))
        printf "\e[${line_number};0H${CLEAR_LINE}${BLK}%5s ${UNDERLINE}${menu_obj[${menu_index}]}${BLK}\n" "$((menu_index+1))."
    fi
    menu_item_start_index_prev=menu_item_start_index

    # Move line to footer's position
    line_number=$(( menu_scroll_size + 2 ))
    echo -ne "\e[${line_number};0H"
}

function ascii_menu_handle_key() {
    local callback_func=${1}
    local -i menu_size=${#menu_obj[@]}

    # Read a single character
    read -r -s -n 1 key
    # Capture trailing characters
    read -r -s -N 1 -t 0.0001 k1
    read -r -s -N 1 -t 0.0001 k2
    read -r -s -N 1 -t 0.0001 k3
    key+=${k1}${k2}${k3}
    case ${key} in
        $'\e[A'|k) # Go Up
            (( (menu_index - 1) == -1 )) && menu_index=$(( menu_size ))
            menu_index=$(( (menu_index - 1) % menu_size ))
            ;;
        $'\e[H'|K) # Go to menu's first item
            menu_index=0
            ;;
        $'\e[B'|j) # Go Down
            menu_index=$(( (menu_index + 1) % menu_size ))
            ;;
        $'\e[F'|J) # Go to menu's last item
            menu_index=$(( menu_size - 1 ))
            ;;
        $'\e[D'|$'\e[C') # Prev/Next page (left/right arrows)
            local -i window_size=$(( LINES - 4 )) # tty height
            local -i menu_scroll_size=menu_size

            # If items outsize scroll view, set scroll view to shell height (window_size)
            (( menu_scroll_size > window_size )) && menu_scroll_size=window_size
            if [[ "${key}" == $'\e[C' ]]
            then
                menu_index=$(( (menu_index + menu_scroll_size) % menu_size ))
            else
                (( (menu_index - menu_scroll_size) < 0 )) && menu_index=$(( menu_size + menu_index ))
                menu_index=$(( (menu_index - menu_scroll_size) % menu_size ))
            fi
            ;;
        '/')
            stty echo
            read -r -e -i "${filter_word}" -p "Search for:" filter_word
            stty -echo
            ;;
        q|Q)
            exit_status=1
            ;;
        *)
            local menu_item_selected="${menu_obj[${menu_index}]}"
            local menu_item_key_selected="${menu_keys_obj[${menu_index}]}"
            [[ -n "${callback_func}" ]] && ${callback_func} ; exit_status=$?
            menu_item_start_index_prev=-1 # repaint in case items changed
            ;;
    esac
}

# @arg: menu_ref (menu items shown)
# @arg: menu_keys_key (menu keys values used for further functions)
function ascii_menu_create() {
    ascii_menu_set_trap
    local -n menu_ref=${1}
    local -n menu_keys_ref=${2}
    local -a menu_ref_copy=( "${menu_ref[@]}" )
    # Actual menu objects been used to avoid alter the references
    local -a menu_keys_obj=( "${menu_keys_ref[@]}" ) menu_obj=( "${menu_ref[@]}" )
    local title="${3}"
    local menu_footer=${4}
    local callback_input=${5}
    local filter_word=""
    local filter_word_prev="${filter_word}"
    local -i menu_item_start_index_prev=-1
    local -i menu_index=0 menu_index_prev=0

    local -i exit_status=0
    while (( exit_status == 0 ))
    do

        if (( ${#menu_ref[@]} == 0 ))
        then
            cout error "No menu items provided"
        fi

        if [[ "${menu_ref[*]}" != "${menu_ref_copy[*]}" ]]
        then
            menu_obj=( "${menu_ref[@]}" )
            menu_keys_obj=( "${menu_keys_ref[@]}" )
            menu_ref_copy=( "${menu_ref[@]}" )
            filter_word_prev=""
        fi

        ascii_menu_filter
        echo -ne "${TOPLEFT}${CLEAR_LINE}${title}\n"
        ascii_menu_show
        [[ -n "${filter_word}" ]] && echo -ne "Current filter «${filter_word}»${CLEAR_LINE}\n"
        echo -ne "${menu_footer}${NOCURSOR}${CLEAR_2BOTTOM_SCREEN}\n"

        menu_index_prev=menu_index
        ascii_menu_handle_key "${callback_input}"
    done
    return 0 # ignore exit status
}
