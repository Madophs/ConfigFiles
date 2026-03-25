#!/bin/env bash

HIDDEN_HOTLIST_DIR="${HOME}/.config/mdsconfig"
HOTLIST_FILE=${HIDDEN_HOTLIST_DIR}/hotlist
mkdir -p "${HIDDEN_HOTLIST_DIR}"
touch "${HOTLIST_FILE}"

[[ ! -v znt_cd_hotlist ]] && declare -g -a znt_cd_hotlist=()

function hotlist_load() {
    znt_cd_hotlist=()
    local line
    while read -r line
    do
        znt_cd_hotlist+=("${line}")
    done < <(cat "${HOTLIST_FILE}")
}

function hotlist_push() {
    if ! grep -w "${PWD}$" "${HOTLIST_FILE}" &> /dev/null;
    then
        echo "${PWD}" >> "${HOTLIST_FILE}"
        znt_cd_hotlist+=("${PWD}")
    fi
}

function hotlist_pop() {
    if (( $# == 0 ))
    then
        local target_dir="${PWD}"
    else
        local target_dir="${*}"
    fi

    grep -v -w "${target_dir}$" "${HOTLIST_FILE}" > "${HOTLIST_FILE}.tmp"
    mv "${HOTLIST_FILE}.tmp" "${HOTLIST_FILE}"
    hotlist_load
}
