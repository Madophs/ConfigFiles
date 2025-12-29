#!/bin/bash

export RED='\e[1;31m'
export RED_DARK='\e[0;31m'
export GREEN='\e[1;32m'
export GREEN_DARK='\e[0;32m'
export YELLOW='\e[1;33m'
export BROWN='\e[0;33m'
export BLUE='\e[1;34m'
export BLUE_DARK='\e[0;34m'
export PURPLE='\e[1;35m'
export PURPLE_DARK='\e[0;35m'
export CYAN='\e[1;36m'
export CYAN_DARK='\e[0;36m'
export WHITE='\e[1;37m'
export GREY='\e[0;37m'
export INVERT='\e[7m'
export UNDERLINE='\e[4m'
export BLK='\e[0;0m'

TOPLEFT='\e[0;0H'            ## Move cursor to top left corner of window
NOCURSOR='\e[?25l'           ## Make cursor invisible
NORMAL_OP='\e[0m\e[?12l\e[?25h'   ## Resume normal operation

function print_stacktrace() {
    for ((i=1; i<=${#funcfiletrace[@]}; i+=1))
    do
        printf "${YELLOW}${funcstack[${i}]}${BROWN}..." >&2
        if (( i == 1 ))
        then
            printf "${GREEN}$(basename "${(%):-%x}")${BLK}\n" >&2
        else
            declare -a file_lineno=($(echo ${funcfiletrace[((i - 1))]} | tr ':' ' '))
            printf "${GREEN}$(basename ${file_lineno[1]}):${CYAN}${file_lineno[2]}${BLK}\n" >&2
        fi
    done

    [[ -v funcstack ]] && return 0 # If zsh return here

    for ((i=0; i<${#BASH_SOURCE[@]}; i+=1))
    do
        printf "${YELLOW}${FUNCNAME[${i}]}${BROWN}...${GREEN}$(basename ${BASH_SOURCE[${i}]})" >&2

        # BASH_LINENO behave very strange when sourcing the scripts
        # it gives inaccurate lines numbers
        if [[ -z ${IS_SOURCED} || ${IS_SOURCED} == NO ]]
        then
            if (( i > 0 ))
            then
                printf ":${CYAN}${BASH_LINENO[$(( i - 1))]}${BLK}" >&2
            fi
        fi

        printf "\n" >&2
    done
}

function cout() {
    local -u type=${1}
    shift

    local messsage="$@"
    case ${type} in
        ERROR|FAIL)
            echo -e "${BLUE}[${RED}${type}${BLUE}]${BLK} ${messsage}" >&2
            [[ "${type}" == ERROR ]] && print_stacktrace
            if [[ -z ${IS_SOURCED} || ${IS_SOURCED} == NO ]]
            then
                exit 1
            else
                kill -n 2 ${SHELL_PID} # SIGINT
            fi
        ;;
        FAULT)
            echo -e "${BLUE}[${PURPLE}FAULT${BLUE}]${BLK} ${messsage}" >&2
        ;;
        DEBUG)
            echo -e "${BLUE}[${PURPLE}DEBUG${BLUE}]${BLK} ${messsage}" >&2
        ;;
        SUCCESS)
            echo -e "${BLUE}[${GREEN}SUCCESS${BLUE}]${BLK} ${messsage}" >&2
        ;;
        WARNING)
            echo -e "${BLUE}[${YELLOW}WARNING${BLUE}]${BLK} ${messsage}" >&2
        ;;
        INFO)
            echo -e "${BLUE}[${CYAN}INFO${BLUE}]${BLK} ${messsage}" >&2
        ;;
    esac
}

if [[ "${REAL_SHELL}" == "zsh" ]]
then
    export cout
    export print_stacktrace
else
    export -f cout
    export -f print_stacktrace
fi
