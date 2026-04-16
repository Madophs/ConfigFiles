#!/bin/bash

source "${MDS_SCRIPTS}/utils/ansi_codes.sh"

[[ ! -v MDS_DEBUG ]] && export MDS_DEBUG=""

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
            if [[ -n "${MDS_DEBUG}" ]]
            then
                echo -e "${BLUE}[${PURPLE}DEBUG${BLUE}]${BLK} «${PURPLE_DARK}$(date '+%T %d-%m-%Y')${BLK}» ${messsage}" 2>> "${MDS_DEBUG}" >&2
            else
                echo -e "${BLUE}[${PURPLE}DEBUG${BLUE}]${BLK} «${PURPLE_DARK}$(date '+%T %d-%m-%Y')${BLK}» ${messsage}" >&2
            fi
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
