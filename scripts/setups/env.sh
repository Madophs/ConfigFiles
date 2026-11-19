#!/usr/bin/env bash
#shellparams --envvars

function set_system_envvars() {
    mkdir -p "${HOME}/.config/environment.d"
    cat > "${HOME}/.config/environment.d/envvars.conf" << EOF
MDS_CONFIG="${MDS_CONFIG}"
MDS_VIM="${MDS_CONFIG}/configs/vim"
MDS_SCRIPTS="${MDS_CONFIG}/scripts"
MDS_SCRIPTS_BIN="${MDS_CONFIG}/scripts/bin"
MDS_DATA="${MDS_DATA}"
MDS_APPS="${MDS_DATA}/apps"
MDS_MEGA="${MDS_DATA}/Mega"
MDS_MEM_BACKUP="${MDS_MEGA}/memcards"
MEM_BACKUP_DIR="${MDS_MEM_BACKUP}"
EOF
}

ARG="${1}"
case $ARG in
    --envvars) set_system_envvars ;;
    *) set_system_envvars
esac
