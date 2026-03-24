#!/bin/bash

source ${MDS_SCRIPTS}/common.sh
HIDDEN_HOSTLIST_DIR=~/.config/mdsconfig
HOSTLIST_FILE=${HIDDEN_HOSTLIST_DIR}/hostlist
mkdir -p ${HIDDEN_HOSTLIST_DIR}
touch ${HOSTLIST_FILE}

function load_hostlist_file() {
    znt_cd_hotlist=()
    cat ${HOSTLIST_FILE} | while read line
    do
        znt_cd_hotlist+=("$line")
    done
}

function is_already_present_in_hostlist() {
    cat ${HOSTLIST_FILE} | grep -w "${@}$" &> /dev/null
    if [[ $(any_error $?) == "YES" ]]
    then
        echo "NO"
    else
        echo "YES"
    fi
}

function push_directory_to_hotlist() {
    CURRENT_DIRECTORY=$@
    if [[ $(is_already_present_in_hostlist ${CURRENT_DIRECTORY}) == "NO" ]]
    then
        echo ${CURRENT_DIRECTORY} >> ${HOSTLIST_FILE}
        znt_cd_hotlist+=("${CURRENT_DIRECTORY}")
    fi
}

function remove_directory_from_hotlist() {
    TARGET_DIRECTORY=$@
    clean_file ${HOSTLIST_FILE}.tmp
    cat ${HOSTLIST_FILE} | while read line
    do
        if [[ ${line} != ${TARGET_DIRECTORY} ]]
        then
            echo ${line} >> ${HOSTLIST_FILE}.tmp
        fi
    done
    mv ${HOSTLIST_FILE}.tmp ${HOSTLIST_FILE}
    load_hostlist_file
}
