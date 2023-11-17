#!/bin/bash

source ${MDS_SCRIPTS}/common.sh

ACTION="--install"
function rust_install() {
    local tmpdir=/tmp/rustup
    mkdir -p ${tmpdir}
    pushd ${tmpdir} &> /dev/null
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh; RETVAL=$?
    popd &> /dev/null
    if [[ $(any_error ${RETVAL}) == YES ]]
    then
        cout error "Failed to install."
    else
        cout success "rust installed."
    fi
}

: ${ACTION:=${1}}
case ${ACTION} in
    --install|--update)
        rust_install
    ;;
esac
