#!/bin/env bash
#shellparams --konsole-colorsheme

source "${MDS_SCRIPTS}/common.sh"

function kde_konsole_colorscheme() {
    fn_create_sym_link "${MDS_CONFIG}/configs/kde/MdsKonsole.colorscheme" "${HOME}/.local/share/konsole/"
}

ARG="${1}"
case $ARG in
    --konsole-colorsheme) kde_konsole_colorscheme ;;
    *) kde_konsole_colorscheme
esac
