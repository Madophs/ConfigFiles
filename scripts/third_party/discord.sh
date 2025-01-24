#!/bin/bash

source ${MDS_SCRIPTS}/common.sh

DISCORD_API_LINK=https://discord.com/api/download\?platform\=linux\&format\=deb

function discord_get_link() {
    curl "${DISCORD_API_LINK}" 2> /dev/null | grep -o -e 'https[^>]*\.deb' | head -n 1
}
function discord_install() {
    if [[ $(is_package_installed discord) == YES ]]
    then
        cout warning 'Package "discord" already installed.'
        return 0
    else
        mkdir -p /tmp/discord
        download $(discord_get_link) /tmp/discord
        install_package "$(ls /tmp/discord/discord*deb | head -n 1)"
    fi
    set_apt_hook discord --update
}

function discord_version() {
    if [[ $(is_package_installed discord) == YES ]]
    then
        local version=$(apt show discord 2> /dev/null | grep -i version | grep -o -w -e '[0-9]\.[0-9]\.[0-9]\+')
    else
        cout error 'Package "discord" is not installed.'
    fi
    echo ${version}
}

function discord_update() {
    local latest_version=$(curl "${DISCORD_API_LINK}" 2> /dev/null | grep -o -e '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -n 1)
    local current_version=$(discord_version)
    if [[ "${latest_version}" != "${current_version}" ]]
    then
        mkdir -p /tmp/discord
        download $(discord_get_link) /tmp/discord
        install_package "$(ls /tmp/discord/discord*deb | head -n 1)"
        cout info "Discord updated..."
    fi
}

function discord_remove() {
    sudo apt remove discord
    remove_apt_hook discord
}

OPTION=$1
: ${OPTION:="--install"}
case ${OPTION} in
    --install)
        discord_install
    ;;
    --remove)
        discord_remove
    ;;
    --version)
        discord_version
    ;;
    --update)
        discord_update
    ;;
    *)
        cout error "Unknown error."
    ;;
esac
