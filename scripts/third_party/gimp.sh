#!/bin/bash -l
#shellparams --install --update --remove

source "${MDS_SCRIPTS}/common.sh"
GIMP_DOWNLOADS_URL="https://www.gimp.org/downloads"
GIMP_ICON_URL="https://upload.wikimedia.org/wikipedia/commons/4/45/The_GIMP_icon_-_gnome.svg"
GIMP_DOWNLOADS_DOM=""
GIMP_BIN="${HOME}/.local/bin/gimp"

function gimp_get_latest_version() {
    echo "${GIMP_DOWNLOADS_DOM}" | grep 'current stable release' | grep -o -E '[0-9]+\.[0-9]+\.[0-9]+'
}

function gimp_get_current_version() {
    if [[ -x "${GIMP_BIN}" ]]
    then
        eval "${GIMP_BIN} --version" | grep -o -E '[0-9]+\.[0-9]+\.[0-9]+'
    else
        echo "Not installed"
    fi
}

function gimp_get_download_link() {
    local href=$(echo "${GIMP_DOWNLOADS_DOM}" | grep -o '".*download.gimp.*x86_64.AppImage"' | tr -d '"')
    echo "https:${href}"
}

function gimp_update() {
    local current_version="$(gimp_get_current_version)"
    local latest_version="$(gimp_get_latest_version)"
    [[ "${current_version}" == "${latest_version}" ]] && return

    cout info "About to install Gimp ${latest_version}"

    # Download install gimp
    local download_link="$(gimp_get_download_link)"
    local filename="$(echo "${download_link}" | awk -F '/' '{print $NF}')"
    download "${download_link}" "/tmp/gimp"
    chmod +x "/tmp/gimp/${filename}"
    cp -f "/tmp/gimp/${filename}" "${GIMP_BIN}"

    # Set desktop app entry
    if [[ ! -f "${HOME}/Pictures/icons/gimp.svg" ]]
    then
        filename="$(echo "${GIMP_ICON_URL}" | awk -F '/' '{print $NF}')"
        download "${GIMP_ICON_URL}" "/tmp/gimp"
        cp "/tmp/gimp/${filename}" "${HOME}/Pictures/icons/gimp.svg"
    fi

    Exec="${GIMP_BIN}"
    GenericName="GNU Image Manipulation Program"
    Icon="${HOME}/Pictures/icons/gimp.svg"
    Name="Gimp"
    Categories="Graphics;"
    add_desktop_app_entry gimp3
}

function gimp_install() {
    if [[ -x "$(which gimp)" ]]
    then
        cout info "Gimp ${gimp_get_current_version} is already installed."
    else
        gimp_update
    fi
    mdssetup add_hook gimp.sh
}

function gimp_remove() {
    rm -f "${GIMP_BIN}" &> /dev/null
    remove_desktop_app_entry gimp
    mdssetup remove_hook gimp.sh
}

GIMP_DOWNLOADS_DOM="$(curl -L -s "${GIMP_DOWNLOADS_URL}")"
if [[ -z "${GIMP_DOWNLOADS_DOM}" ]]
then
    cout fail "Gimp: unable to retrieve download metadata"
    exit 0
fi

action="${1}"
case "${action}" in
    --install)
        gimp_install
        ;;
    --update)
        gimp_update
        ;;
    --remove)
        gimp_remove
        ;;
    *)
        cout fail "Gimp: invalid option «${action}»"
        ;;
esac
