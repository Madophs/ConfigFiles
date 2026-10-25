#!/bin/bash
#shellparams --install --setup --update --latest-version

source "${MDS_SCRIPTS}/common.sh"

function nvim_latest_version() {
    wget -qO - https://github.com/neovim/neovim/releases | grep -o -e 'Nvim [0-9]\+\.[0-9]\+\.[0-9]' | grep -m 1 -o -e '[0-9]\+\.[0-9]\+\.[0-9]'
}

function nvim_install() {
    local download_dir='/tmp/nvim/'
    local filename="nvim-linux-x86_64.appimage"
    mkdir -p "${download_dir}"

    cout info "Installing Neovim"
    download "https://github.com/neovim/neovim/releases/download/v$(nvim_latest_version)/${filename}" ${download_dir}
    sudo chmod +x "${download_dir}${filename}"
    sudo chown "${USER}:${USER}" "${download_dir}${filename}"

    if [[ -f /usr/bin/nvim ]]; then
        sudo rm /usr/bin/nvim
    fi

    if sudo cp -f "${download_dir}${filename}" /usr/bin/nvim;
    then
        cout success "NeoVim installed successfully."
        mdssetup add_hook nvim.sh
    else
        cout error "Something went wrong."
    fi
}

function nvim_setup() {
    local -r nvim_config="${HOME}/.config/nvim"
    local -r lua_dir="${nvim_config}/lua"
    local -r config="${lua_dir}/config/"
    local -r plugins="${lua_dir}/plugins/"
    local -r postconfig="${lua_dir}/postconfig/"

    # Clean whatever is in the directory
    rm -rf "${lua_dir}"
    rm -rf "${nvim_config}/init.lua"
    # Create plugin directory structure
    mkdir -p "${config}" "${plugins}" "${postconfig}"

    fn_create_sym_link "${MDS_VIM}/lua/init.lua" "${nvim_config}/"
    fn_create_sym_link "${MDS_VIM}/lua/lazy.lua" "${config}"
    fn_create_sym_link "${MDS_VIM}/lua/plugins1.lua" "${plugins}"
    fn_create_sym_link "${MDS_VIM}/lua/cmp.lua" "${plugins}"
    fn_create_sym_link "${MDS_VIM}/lua/snacks.lua" "${plugins}"
    fn_create_sym_link "${MDS_VIM}/lua/cmp_config.lua" "${postconfig}"
}

function nvim_update() {
    if [[ ! -x "$(which nvim)" ]]
    then
        cout error "Nvim not installed"
    fi
    local latest_version current_version
    latest_version=$(nvim_latest_version)
    current_version=$(nvim -v | grep -m 1 -o -e '[0-9]\+\.[0-9]\+.[0-9]\+')
    if [[ "${current_version}" != "${latest_version}" && -n "${latest_version}" ]]
    then
        nvim_install
    fi
}

OPTION=$1
: "${OPTION:="--install"}"
case ${OPTION} in
    --install)
        nvim_install
        ;;
    --update)
        nvim_update
        ;;
    --setup)
        nvim_setup
        ;;
    --latest-version)
        nvim_latest_version
        ;;
esac
