#!/bin/env bash
#shellparams --setup --undo-setup

source "${MDS_SCRIPTS}/common.sh"

declare -r xkb_configs="${MDS_CONFIG}/configs/xkb"
declare -r x11_xkb_dir="/usr/share/X11/xkb"
declare -r xkb_usr_rules="${HOME}/.config/xkb/rules/"

function xkb_setup() {
    mkdir -p "${xkb_usr_rules}"
    fn_create_sym_link "${xkb_configs}/mds" "${x11_xkb_dir}/symbols"
    fn_create_sym_link "${xkb_configs}/evdev.xml" "${xkb_usr_rules}"
}

function xkb_undo_setup() {
    unlink "${xkb_usr_rules}/evdev.xml"
    sudo unlink "${x11_xkb_dir}/symbols/mds"
}

ARG="${1}"
case $ARG in
    --setup) xkb_setup ;;
    --undo-setup) xkb_undo_setup ;;
    *) pwarn "No option provided"
esac
