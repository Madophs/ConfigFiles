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
    preparse_args args_map "name=output short_option=-o args=yes"
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

function gdiff() {
    local git_status=$(git status -u 2> /dev/null)
    local -i git_status_lines=$(echo "${git_status}" | wc -l)
    local not_staged_files=$(echo "${git_status}" | grep -m 1 -A${git_status_lines} 'not staged for commit')
    local -a modified_files=( $(echo "${not_staged_files}" | grep 'modified:' | sed 's|modified:||g;s|^[[:space:]]\+||g') )
    if [[ -n "${modified_files}" ]]
    then
        local -i counter=1
        for item in "${modified_files[@]}"
        do
            cout info "View file(${counter}/${#modified_files[@]}) '${item}' (y/n)"
            read option
            if [[ "${option}" =~ [yY] ]]
            then
                nvim "${item}" -c Gdiffsplit
            fi
            counter+=1
        done
    else
        cout info "No non-staged modified files."
    fi
}

function okular_clear_old_pages_history() {
    local okular_docdata="${HOME}/.local/share/okular/docdata"
    find "${okular_docdata}" -name "*.xml" | xargs -d '\n' -L 1 sed -i '/oldPage/d'
}

# Only works with cambride dictionary
# Args: [lang (us, uk) => preferred language dialect pronunciation for immediate download]
function gaudio() {
    local lang="${1}"
    local audio_url="$(xclip -selection clipboard -o)"
    local base_domain="$(echo "${audio_url}" | grep -o -e "https://[a-zA-Z\._]\+\.\(org\|com\)")"
    test "${base_domain}" != "https://dictionary.cambridge.org" && cout error "Invalid URL"

    local target_dir="/home/madophs/Downloads/language audios/english"
    local searched_word=$(echo "${audio_url}" | grep -o -e '[^\/]\+$')
    local html_dom="$(curl -L -s "${audio_url}")"

    # Trim word of the day
    local wotd_line_number=$(echo "${html_dom}" | grep -m 1 -n -i 'word of the day' | grep -o '^[0-9]\+')
    if [[ -n "${wotd_line_number}" ]]
    then
        html_dom=$(echo "${html_dom}" | sed -n "1,${wotd_line_number}{p}")
    fi

    local -a mp3_list=( $(echo "${html_dom}" | grep -o '\/media.*\.mp3' | sort | uniq) "quit")
    local -i options_count=$(echo "${mp3_list[@]}" | tr ' ' '\n' | wc -l)
    local -i option
    while (( $# == 0 )) # Loop if no args provided
    do
        cout info "Word: '${searched_word}'"
        echo "${mp3_list[@]}" | tr ' ' '\n' | nl
        read option
        if (( option > options_count ))
        then
            cout fault "Option out of bounds"
            continue
        fi

        test "${option}" -lt 1 && break
        test "${mp3_list[${option}]}" = "quit" && break

        local mp3_audio="${mp3_list[${option}]}"
        local mp3_filename="$(echo "${mp3_audio}" | awk -F '/' '{print $NF}')"
        cout info "Word: ${searched_word}, Audio: ${mp3_filename}"
        cout info "(D)ownload (P)lay (Q)uit"
        read action
        case "${action}" in
            d|D)
                wget -nc -qq "${base_domain}/${mp3_audio}" -P '/tmp/audios' || cout error "Download failed"
                cp "/tmp/audios/${mp3_filename}" "${target_dir}/${searched_word}.mp3"
                play "${target_dir}/${searched_word}.mp3" &> /dev/null
                break
                ;;
            p|P)
                wget -nc -qq "${base_domain}/${mp3_audio}" -P '/tmp/audios' || cout error "Download failed"
                play "/tmp/audios/${mp3_filename}" &> /dev/null
                ;;
            q|Q)
                break
                ;;
        esac
    done

    if [[ -n "${lang}" ]]
    then
        local lang_pron="${lang}_pron"
        mp3_list=($(echo "${mp3_list}" | tr ' ' '\n' | grep "${lang_pron}"))
        [[ ${#mp3_list[@]} -eq 0 ]] && cout error "No audios found for <${lang}>"

        local mp3_audio="${mp3_list[1]}"
        local mp3_filename="$(echo "${mp3_audio}" | awk -F '/' '{print $NF}')"
        wget -nc -qq "${base_domain}/${mp3_audio}" -P '/tmp/audios' || cout error "Download failed"
        cp "/tmp/audios/${mp3_filename}" "${target_dir}/${searched_word}.mp3"
        play "${target_dir}/${searched_word}.mp3" &> /dev/null
    fi
}

function __custcmds() {
    local curr_script="${MDS_SCRIPTS}/custom_cmds.sh"
    cout info "List of commands"
    grep -e '^function.*{' "${curr_script}" | awk -F'[ ()]' '{print $2}' | sort
}
