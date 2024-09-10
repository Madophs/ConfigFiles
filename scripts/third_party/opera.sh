#!/bin/bash

source ${MDS_SCRIPTS}/common.sh
PACKAGE_NAME=opera-stable
OPERA_FTP_URL=https://download5.operacdn.com/ftp/pub/opera/desktop

LIB_NAME=libffmpeg.so
DOWNLOAD_DIR='/tmp/ffmpeg'
FFMPEG_REPO="https://github.com/nwjs-ffmpeg-prebuilt/nwjs-ffmpeg-prebuilt/releases"
OPERA_BIN=$(readlink -f $(which opera))
TARGET_PATH=$(echo ${OPERA_BIN} | grep -o -e '^/.\+/' | sed 's|/$|/lib_extra|g')

if [[ ! -d ${TARGET_PATH} ]]
then
    sudo mkdir -p ${TARGET_PATH}
fi

function do_opera_get_version() {
    local current_version=$(opera --version 2> /dev/null)
    if [[ ${current_version} != "" ]]
    then
        echo ${current_version}
    else
        echo "NA"
    fi
}

function do_opera_show_ffmpeg_lib_versions() {
    cout info " ffmpeg library versions:"
    wget -qO - ${FFMPEG_REPO} | grep -A20 datetime |
        grep -E -o -e '20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]|[0-9]\.[0-9]+\.[0-9]$' |
        xargs -L 2 echo | sort | awk -F ' ' '{print "\t"$1" => "$2}' | grep -B10 -A10 -w --color=always "$(< ${TARGET_PATH}/version.txt)"
}

function do_opera_show_versions() {
    cout info " opera versions:"
    local opera_version=$(do_opera_get_version)
    local latest_versions=$(wget -qO - ${OPERA_FTP_URL} | grep -E '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*' | \
        sed -e 's|<.*">||g' -e 's|/<.*a>||g' | awk '{print $1" "$2}' | sort -k2.2 -t '.' | uniq | tail -n 10 | awk '{print "\t"$NF" => "$1}')

    echo -e "${latest_versions}" | grep -B10 -A10 -w --color=always ${opera_version} || echo -e "${latest_versions}"
    echo
    cout info " Current version: " ${opera_version}
}

function get_opera_download_link() {
    local package_version=${1}
    local repo_url=${OPERA_FTP_URL}/${package_version}/linux
    local package_file=$(wget -qO - ${repo_url} | grep -o -e '>.*<' | egrep -v 'rpm|deb\.' | grep -o -e 'opera-stable.*deb')
    echo ${repo_url}/${package_file}
}

function do_opera_install() {
    local package_version=${args_map["--install"]}
    if [[ -z ${package_version} ]]
    then
        package_version=$(wget -qO - ${OPERA_FTP_URL} | grep -o -e '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*' | sort -k2.2 -t '.' | uniq | tail -n 1)
    else
        cout info "Using package versions: ${package_version}"
    fi

    local download_link=$(get_opera_download_link ${package_version})
    local download_dir=/tmp/opera_tmp
    download ${download_link} ${download_dir}
    local package_path=$(ls -lt ${download_dir}/opera*${package_version}*deb | head -n 1 | awk  '{print $NF}')

    unhold_package ${PACKAGE_NAME}
    install_package ${package_path}
    hold_package ${PACKAGE_NAME}
}

function do_opera_update() {
    if [[ $(is_package_installed ${PACKAGE_NAME}) == YES ]]
    then
        kill_opera
        unhold_package ${PACKAGE_NAME}
        update_package ${PACKAGE_NAME}
        hold_package ${PACKAGE_NAME}
    else
        cout error "${PACKAGE_NAME} is not installed."
    fi
}

function do_set_autoupdate() {
    local apt_opera_autofix='/etc/apt/apt.conf.d/99fix-opera'
    sudo touch ${apt_opera_autofix}
    sudo truncate -s 0 ${apt_opera_autofix}
    echo 'DPkg::Pre-Invoke {"stat -c %Z $(readlink -f $(which opera)) > /tmp/opera.timestamp";};' | sudo tee -a ${apt_opera_autofix}
    echo 'DPkg::Post-Invoke {"if [ `stat -c %Z $(readlink -f $(which opera))` -ne `cat /tmp/opera.timestamp` ]; then export MDS_SCRIPTS={{}};export MDS_TRAP_CMD={{trap}};${MDS_SCRIPTS}/third_party/opera.sh --install-ffmpeg; fi; rm /tmp/opera.timestamp";};' | sed -e "s|{{}}|${MDS_SCRIPTS}|g" -e "s|{{trap}}|${MDS_TRAP_CMD}|g" | sudo tee -a ${apt_opera_autofix}
}

function get_opera_pid() {
    ps -ef | grep -e "${OPERA_BIN}$" | grep -v grep | awk '{print $2}'
}

function start_opera() {
    local opera_pid=$(get_opera_pid)
    if [[ -n "${opera_pid}" ]] ; then return 0; fi;

    add_cmd_to_trap $(get_parent_pid_by_regex "^[a-z/]*\(zsh\|bash\)$") "cout info 'starting opera...'; opera &> /dev/null &"
}

function kill_opera() {
    local opera_pid=$(get_opera_pid)
    if [[ -z ${opera_pid} ]] ; then return 0; fi;

    kill -s TERM ${opera_pid}

    # Wait for opera to exit
    declare -i timeout_cnt=10
    while [[ -n ${opera_pid} ]]
    do
        if [[ ${timeout_cnt} == 0 ]]
        then
            cout warning "It seems that Opera browser is running..."
            cout warning "Please consider terminate the process before proceed."
            exit 1
        fi

        # Enough time to click Opera's exit confirmation dialog
        if (( ${timeout_cnt} != 10 ))
        then
            cout warning "Please check Opera's exit warning dialog."
        fi

        sleep 1
        timeout_cnt=$(( timeout_cnt - 1 ))
        opera_pid=$(get_opera_pid)
    done
}

# By default Opera doesn't own some media codecs permissions to play some video formats on the internet
function do_opera_install_ffmpeg() {
    # Avoid executing twice
    args_map["--install-ffmpeg_avail"]=NO

    if [[ -n ${args_map["--install-ffmpeg"]} ]]
    then
        local ffmpeg_lib_version="${args_map["--install-ffmpeg"]}"
    else
        local latest_release=$(wget --max-redirect 0 ${FFMPEG_REPO}/latest 2>&1 | grep Location | grep -o 'https:.\+[0-9]')
        local ffmpeg_lib_version=$(echo ${latest_release} | grep -o -e '[0-9]\+\.[0-9]\+\.[0-9]\+$')
    fi

    if [[ -f "${TARGET_PATH}/version.txt" && "${ffmpeg_lib_version}" == "$(<${TARGET_PATH}/version.txt)" ]]
    then
        cout info "ffmpeg ${ffmpeg_lib_version}: nothing to update."
        return 0
    fi

    # Prepare temp files
    local download_tmp_dir='/tmp/tmp_ffmpeg'
    mkdir -p ${download_tmp_dir}
    echo ${ffmpeg_lib_version} > ${download_tmp_dir}/version.txt

    # Download link from Github
    local filename="${ffmpeg_lib_version}-linux-x64.zip"
    local download_link=$(echo ${FFMPEG_REPO}/latest | sed 's|/latest|/download|g')/${ffmpeg_lib_version}/${filename}

    # Download and installation
    download ${download_link} ${download_tmp_dir}
    sudo unzip -o ${download_tmp_dir}/${filename} -d ${TARGET_PATH}
    sudo mv ${download_tmp_dir}/version.txt ${TARGET_PATH}

    rm -rf ${download_tmp_dir}

    start_opera
}

function do_remove_ffmpeg() {
    kill_opera
    sudo rm -ri "${TARGET_PATH}"
    start_opera
}

function do_opera_install_with_ffmpeg() {
    kill_opera
    do_opera_install
    do_opera_install_ffmpeg
    start_opera
}

function do_opera_list_all_versions() {
    do_opera_show_ffmpeg_lib_versions
    echo
    do_opera_show_versions
}

function do_opera_remove() {
    sudo apt remove ${PACKAGE_NAME}
}

declare -i calling_pid=$(get_parent_pid_by_regex "/bin/bash /[/a-zA-Z_]\+/opera.sh" 2)
if (( ${calling_pid} != 1 ))
then
    cout warning "Exiting opera's APT hook script as it was directly executed by user."
    exit 0
fi

declare -A args_map
preparse_args args_map \
    "option=--install           args=opt    func=do_opera_install_with_ffmpeg" \
    "option=--remove            args=no     func=do_opera_remove" \
    "option=--update            args=no     func=do_opera_update" \
    "option=--install-ffmpeg    args=opt    func=do_opera_install_ffmpeg" \
    "option=--remove-ffmpeg     args=no     func=do_remove_ffmpeg" \
    "option=--set-autoupdate    args=no     func=do_set_autoupdate" \
    "option=--versions          args=no     func=do_opera_list_all_versions"
parse_args args_map n "${@}"
exec_args_flow args_map --install --update --install-ffmpeg --versions --remove-ffmpeg --remove --set-autoupdate
