#!/bin/bash

source ${MDS_SCRIPTS}/common.sh

function cdm() {
    if (( $# != 1 ))
    then
        cout error "Usage: cdm [problem_url]"
        return
    fi

    local problem_url="${1}"
    local online_judge="$(echo "${problem_url}" | grep -o -e '[a-z]\+\.\(com\|org\)')"
    case "${online_judge}" in
        "onlinejudge.org")
            local is_uva_pdf_url=$(echo "${problem_url}" | grep -e '^https:.\+\.pdf$')
            if [[ -n "${is_uva_pdf_url}" ]]
            then
                local -i problem_id=$(echo "${problem_url}" | grep -o -e '[0-9]\+.pdf$' | grep -o -e '^[0-9]\+')
            else
                local -i problem_id=$(curl -L -s "${problem_url}" | grep -e '<h3>[0-9]\+ - .\+<\/h3>' | awk -F '[<>]' '{print $3}' | grep -o -e '^[0-9]\+')
            fi
            local -i id_suffix=$(( problem_id / 100 ))
            local target_directory="${GIT_REPOS}/UVA_Online_Judge_Solutions/volume_${id_suffix}"
            ;;
        "aceptaelreto.com")
            local -i problem_id=$(curl -L -s "${problem_url}" | grep -e 'setDocumentTitle' | awk -F '[/]' '{print $2}' | grep -o -e '[0-9]\+')
            local -i id_suffix=$(( problem_id / 100 ))
            local target_directory="${GIT_REPOS}/Competitive-Programming/Acepta el reto/Volumen ${id_suffix}"
            ;;
        *)
            if [[ -n "${online_judge}" ]]
            then
                cout error "Unsupported online judge <${online_judge}>"
            else
                cout error "Invalid arguments"
            fi
            ;;
    esac

    mkdir -p "${target_directory}"
    cd "${target_directory}"
    mdscode -g -u "${problem_url}"
}

function cl() {
    if [[ "${1}" != "" ]]
    then
        cd "${1}" && lsd -l
        return 0
    fi

    local target_directory="$(ls -F | grep -o -e '.\+\/$' | fzf)"
    if [[ "${target_directory}" != "" ]]
    then
        cd "${target_directory}" && lsd -l
    fi
}

function Asm() {
    declare -A args_map
    preparse_args args_map "option=-o args=yes"
    parse_args args_map y "${@}"

    local filename=$(echo "${args_map["extra"]}" | awk '{print $NF}')
    local file_extension=$(get_file_extension ${filename})
    local output=$([ -z "${args_map["-o"]}" ] && get_filename_without_extension ${filename} || echo "${args_map["-o"]}")

    case ${file_extension} in
        s)
            as $(echo ${args_map["extra"]}) -o "${output}.o" \
                && ld "${output}.o" -o ${output}.out
            ;;
        asm)
            nasm -felf64 ${filename} -o "${output}.o" \
                && ld "${output}.o" -o ${output}.out
            ;;
        *)
            cout error "File extension no recognized"
            ;;
    esac
}

function Ppid() {
    missing_argument_validation 1 ${1}
    typeset -i pid=${1}
    ps -oppid -opid -ocmd -p ${pid} | head -n 1
    while (( ${pid} != 1 ))
    do
        ps -oppid -opid -ocmd -p ${pid} | tail -n 1
        pid=$(ps -oppid -p ${pid} | tail -n 1)
    done
}

function yy() {
	yazi "$@" --cwd-file="${APPCWD}"
	if cwd="$(cat -- "${APPCWD}")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]
    then
        add_cmd_to_trap ${SHELL_PID} "$(echo "${cwd}" | sed '1s/^\(.*\)/cd "\1"/g')"
	fi
}

function vicd() {
    vifm --choose-dir - "$@" > "${APPCWD}"
	if cwd="$(cat -- "${APPCWD}")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]
    then
        add_cmd_to_trap ${SHELL_PID} "$(echo "${cwd}" | sed '1s/^\(.*\)/cd "\1"/g')"
	fi
}

function goodreads() {
    local total_pages=$( (( ${1} > ${2} )) && echo ${1} || echo ${2})
    local read_pages=$( (( ${1} < ${2} )) && echo ${1} || echo ${2})
    echo "${read_pages} / ${total_pages} * 100" | genius --floatresult
}

function __custcmds() {
    local curr_script="${MDS_SCRIPTS}/custom_cmds.sh"
    cout info "List of commands"
    grep -e '^function.*{' "${curr_script}" | awk -F'[ ()]' '{print $2}' | sort
}
