#!/bin/bash

source "${MDS_SCRIPTS}/utils/ansi_codes.sh"

[[ ! -v MDS_DEBUG ]] && export MDS_DEBUG=""

function print_stacktrace() {
    local file lineno
    for ((i=1; i<=${#funcfiletrace[@]}; ++i))
    do
        echo -ne "${YELLOW}${funcstack[${i}]}${BROWN}..." >&2
        IFS=':' read -r -s file lineno <<< "${funcfiletrace[i]}"
        if (( i == 1 ))
        then
            echo -e "${GREEN}$(basename "${file}")${BLK}" >&2
        else
            echo -e "${GREEN}$(basename "${file}"):${CYAN}${lineno}${BLK}" >&2
        fi
    done

    [[ -v funcstack ]] && return 0 # If zsh return

    for ((i=0; i<${#BASH_SOURCE[@]}; ++i))
    do
        echo -ne "${YELLOW}${FUNCNAME[i]}${BROWN}...${GREEN}$(basename "${BASH_SOURCE[i]}")" >&2
        # BASH_LINENO behave very strange when sourcing the scripts
        # it gives inaccurate lines numbers
        if (( i > 0 ))
        then
            echo -ne ":${CYAN}${BASH_LINENO[i-1]}${BLK}" >&2
        fi
        echo >&2
    done
}

function cout() {
    local -u type=${1}
    shift
    local message="${*}"
    case ${type} in
        ERROR|FAIL)
            echo -e "${BLUE}[${RED}${type}${BLUE}]${BLK} ${message}" >&2
            [[ "${type}" == ERROR ]] && print_stacktrace
            # kill script if not executing on user's shell
            if (( SHELL_PID != $$ ))
            then
                exit 1
            else
                kill -n 2 "${SHELL_PID}" # SIGINT
            fi
            ;;
        FAULT)
            echo -e "${BLUE}[${PURPLE}FAULT${BLUE}]${BLK} ${message}" >&2
            ;;
        DEBUG)
            if [[ -n "${MDS_DEBUG}" ]]
            then
                echo -e "${BLUE}[${PURPLE}DEBUG${BLUE}]${BLK} «${PURPLE_DARK}$(date '+%T %d-%m-%Y')${BLK}» ${message}" 2>> "${MDS_DEBUG}" >&2
            else
                echo -e "${BLUE}[${PURPLE}DEBUG${BLUE}]${BLK} «${PURPLE_DARK}$(date '+%T %d-%m-%Y')${BLK}» ${message}" >&2
            fi
            ;;
        SUCCESS)
            echo -e "${BLUE}[${GREEN}SUCCESS${BLUE}]${BLK} ${message}" >&2
            ;;
        WARNING)
            echo -e "${BLUE}[${YELLOW}WARNING${BLUE}]${BLK} ${message}" >&2
            ;;
        INFO)
            echo -e "${BLUE}[${CYAN}INFO${BLUE}]${BLK} ${message}" >&2
            ;;
    esac
}
