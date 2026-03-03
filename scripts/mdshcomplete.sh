#!/bin/bash
[[ "${REAL_SHELL}" != "bash" ]] && return

source /usr/share/bash-completion/bash_completion

function get_cursor_position() {
  # Save current terminal settings and set raw mode, no echo
  exec < /dev/tty
  local old_stty=$(stty -g)
  stty raw -echo min 0

  # Request cursor position (ESC[6n)
  printf "\\033[6n" > /dev/tty

  # Read the response from the terminal: ESC[row;columnR
  IFS=';' read -ra pos -d R

  # Restore terminal settings
  stty "${old_stty}"

  # Extract row and column, adjusting for 0-based indexing if needed (terminal is 1-based)
  CROW=${pos[0]:2} # Strip the leading "ESC["
  CCOL=${pos[1]}
}

function get_completions() {
    local completion COMP_CWORD COMP_LINE COMP_POINT COMP_WORDS COMPREPLY=()

    # load bash-completion if necessary
    #declare -F _completion_loader &>/dev/null || {
        #source /usr/share/bash-completion/bash_completion
    #}

    COMP_LINE=$*
    COMP_POINT=${#COMP_LINE}

    eval set -- "$@"

    COMP_WORDS=("$@")

    # add '' to COMP_WORDS if the last character of the command line is a space
    [[ ${COMP_LINE[@]: -1} = ' ' ]] && COMP_WORDS+=('')

    # index of the last word
    COMP_CWORD=$(( ${#COMP_WORDS[@]} - 1 ))

    # for single/partial cmds queries are done through compgen
    if (( ${#COMP_WORDS[@]} == 1 ))
    then
        # compgen -c queries all commands in $PATH
        compgen -c "${@}" | LC_ALL=C sort | uniq
        return
    fi

    # determine completion function
    completion=$(complete -p "$1" 2>/dev/null | awk '{print $(NF-1)}')

    # run _completion_loader only if necessary
    if [[ -z ${completion} ]]
    then
        # load completion
        _completion_loader "$1"

        # detect completion
        completion=$(complete -p "$1" 2>/dev/null | awk '{print $(NF-1)}')
    fi

    # ensure completion was detected
    [[ -n ${completion} ]] || return 1

    # execute completion function
    "${completion}"

    # print completions to stdout
    printf '%s\n' "${COMPREPLY[@]}" | LC_ALL=C sort
}

function __mdsh_key_handling() {
    # Read a single character
    IFS= read -s -n 1 key
    # Capture trailing characters
    read -s -N 1 -t 0.0001 k1
    read -s -N 1 -t 0.0001 k2
    read -s -N 1 -t 0.0001 k3
    key+=${k1}${k2}${k3}
    case "${key}" in
        $'\e[A'|k*|u*) # Move Up: up arrow,k
            case "${key}" in
                u*) complist_index=$(( complist_index - (num_cols * scroll_slice) )) ;;
                *) complist_index=$(( complist_index - num_cols )) ;;
            esac

            if (( complist_index < 0 ))
            then
                complist_index+=num_cols
                local -i rem=$(( complist_index % num_cols ))
                complist_index=$(( num_cols * num_rows + rem ))
                while (( complist_index >= complist_size ))
                do
                    complist_index=$(( complist_index - num_cols ))
                done
            fi
            ;;
        $'\e[B'|j*|d*) # Move Down: down arrow,j
            case "${key}" in
                d*) complist_index+=$(( num_cols * scroll_slice )) ;;
                *) complist_index+=num_cols ;;
            esac

            if (( complist_index >= complist_size ))
            then
                complist_index=$(( complist_index % num_cols ))
            fi
            ;;
        $'\e[D'|h*) # Move left: <-,h
            complist_index=$(( complist_index - 1 ))
            (( complist_index < 0 )) && complist_index=$(( complist_size - 1 ))
            ;;
        $'\e[C'|$'\t'|l*) # Move right: <-,tab,l
            complist_index=$(( (complist_index + 1) % complist_size ))
            ;;
        $'\e[H') # Go to menu's first item
            complist_index=0
            ;;
        $'\e[F') # Move to last item
            complist_index=$(( complist_size - 1))
            ;;
        $''|[qQ]) # Quit: ESC
            is_job_done=1
            ;;
        "")
            local cchar="${READLINE_LINE:${READLINE_POINT}:1}"
            local pchar="${READLINE_LINE:$((READLINE_POINT-1)):1}"
            # 1.- git[''] 2.- git[' '] 3.- git add[''] repo
            if [[ ( -z "${cchar}" || "${cchar}" == " " ) && "${pchar}" =~ [^\ ] ]]
            then
                for (( i=$((READLINE_POINT-1)); i>=0; i-=1 ))
                do
                    [[ "${READLINE_LINE:${i}:1}" == " " ]] && break
                done
                READLINE_LINE="${READLINE_LINE:0:$(( i+1 ))}${complist[${complist_index}]}${READLINE_LINE:${READLINE_POINT}}"
                READLINE_POINT=${#READLINE_LINE}
            # 4.- git [''] => git <add>
            elif [[ -z "${cchar}" && "${pchar}" == " " ]]
            then
                READLINE_LINE="${READLINE_LINE}${complist[${complist_index}]}"
                READLINE_POINT=${#READLINE_LINE}
            # 5.- git b[r]a => git <branch>
            elif [[ -n "${cchar}" ]]
            then
                for (( i=$((READLINE_POINT-1)); i>=0; i-=1 ))
                do
                    [[ "${READLINE_LINE:${i}:1}" == " " ]] && break
                done
                for (( j=$((READLINE_POINT+1)); j<${#READLINE_LINE}; j+=1 ))
                do
                    [[ "${READLINE_LINE:${j}:1}" == " " ]] && break
                done
                READLINE_LINE="${READLINE_LINE:0:$(( i+1 ))}${complist[${complist_index}]}${READLINE_LINE:${j}}"
            else
                # replace with whatever suggestion is selected
                READLINE_LINE="${complist[${complist_index}]}"
                READLINE_POINT=${#READLINE_LINE}
            fi
            is_job_done=1
            ;;
    esac
}

function __mdsh_print_suggestions() {
    num_cols=$(( COLUMNS / col_width ))
    num_rows=$(( complist_size / num_cols ))
    scroll_slice=$(( num_rows / 2 ))
    (( (complist_size % num_cols) != 0 )) && num_rows+=1 # Round up
    local -i cols_padding=$(( (COLUMNS % col_width) / num_cols )) # space between cols
    local -i avail_lines=$(( LINES - BOTTOM_PADDING - CROW ))

    end_index=$(( num_rows * num_cols ))
    (( end_index > complist_size )) && end_index=complist_size

    if (( num_rows > (LINES - BOTTOM_PADDING) ))
    then
        local -i scroll_window_size=$(( LINES - BOTTOM_PADDING - 2 ))
        local -i current_row=$(( complist_index / num_cols ))

        # upper/lower item padding
        scroll_slice=$(( scroll_window_size / 2 ))

        local -i row_index=0
        # update row if position is beyond scroll slice (upper bound)
        (( current_row - scroll_slice > 0 )) && row_index=$(( current_row - scroll_slice ))

        end_index=$(( (row_index + scroll_window_size) * num_cols ))
        start_index=$(( row_index * num_cols ))

        # Print all possible items above index in case we're near the list's end (bottom)
        (( end_index > complist_size )) && start_index=$(( (num_rows - scroll_window_size) * num_cols ))
        (( end_index > complist_size )) && end_index=$(( complist_size ))

        if (( is_cursor_repositioned == 0 && CROW > 1 ))
        then
            local -i downward_scrolls=$(( CROW - 1 ))
            printf "${RESTORE_CURSOR}"
            printf "\e[${downward_scrolls}S\e[$(( downward_scrolls ))A"
            printf "${SAVE_CURSOR}\n"
            CROW=1
            is_cursor_repositioned=1
        fi
    else
        # if there's no space to print, then we will scroll and reposition
        if (( avail_lines < num_rows && is_cursor_repositioned == 0 ))
        then
            if (( avail_lines > 0 ))
            then
                local -i downward_scrolls=$(( num_rows - avail_lines ))
            else
                local -i downward_scrolls=$(( num_rows + BOTTOM_PADDING ))
            fi
            printf "${RESTORE_CURSOR}"
            printf "\e[${downward_scrolls}S\e[$(( downward_scrolls ))A"
            printf "${SAVE_CURSOR}\n"
            CROW=$(( CROW - downward_scrolls ))
            is_cursor_repositioned=1
        fi
    fi

    for (( i=start_index; i<end_index; i+=num_cols ))
    do
        for (( j=i; j<end_index && j<(i+num_cols); j+=1 ))
        do
            if (( complist_index == j ))
            then
                printf "${INVERT}%-$(( (col_width+cols_padding) ))s${INVERT_BLK}" ${complist[j]}
            else
                printf "%-$(( (col_width+cols_padding) ))s" ${complist[j]}
            fi
        done
        (( j+num_cols > end_index )) && printf "\n${CLEAR_LINE}" || echo
    done
}

function mdshcomplete_main() {
    local -a complist=( $(get_completions "${READLINE_LINE}" ))
    (( ${#complist} == 0 )) && return
    local -i complist_size=${#complist[@]}

    local -i col_width=0
    for item in "${complist[@]}"
    do
        if (( col_width < (${#item}+2) ))
        then
            col_width=$(( ${#item} + 2 )) # 2 columns for padding
        fi
    done

    get_cursor_position

    # Create some space if we're at the very bottom
    # scroll down to create space, them move cursor up
    (( CROW == LINES )) && printf "\e[1S\e[1A"

    # Useful margin to manipulate cursor downwards motion (\n or \e[B)
    # as they don't have any affect if bottom lines are already reached
    declare -g -i BOTTOM_PADDING=1

    local -i start_index=0 end_index=0
    local -i num_rows=0 num_cols=0
    local -i scroll_slice=0

    # cursor reposition only need once if required
    local -i is_cursor_repositioned=0
    local -i complist_index=0
    local -i is_job_done=0

    printf "${NOCURSOR}"
    while (( is_job_done == 0 ))
    do
        printf "${SAVE_CURSOR}$( echo "${PS1@P}" | tail -n 1)${READLINE_LINE}\n"
        __mdsh_print_suggestions
        __mdsh_key_handling
        printf "${RESTORE_CURSOR}"
    done
    printf "${SHOWCURSOR}${CLEAR_LINE}${CLEAR_2BOTTOM_SCREEN}"
}
