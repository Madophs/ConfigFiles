#!/bin/bash

source ${MDS_SCRIPTS}/common.sh

function cdm() {
    local problem_id=$(( ${1} ))
    local id_suffix=$(( problem_id / 100 ))
    local target_directory="${GIT_REPOS}/UVA_Online_Judge_Solutions/volume_${id_suffix}"
    mkdir -p "${target_directory}"
    cd "${target_directory}"
    mdscode -g -n "${@}"
}

function Asm() {
    declare -A args_map
    preparse_args args_map "prefix=-o args=yes"
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
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

function vicd()
{
    local dst="$(command vifm --choose-dir - "$@")"
    if [ -z "$dst" ]
    then
        echo 'Directory picking cancelled/failed'
        return 1
    fi
    cd "$dst"
}
