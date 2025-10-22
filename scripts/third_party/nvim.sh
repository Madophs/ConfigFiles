#!/bin/bash

source ${MDS_SCRIPTS}/common.sh

function nvim_latest_version() {
    wget -qO - https://github.com/neovim/neovim/releases | grep -o -e 'Nvim [0-9]\+\.[0-9]\+\.[0-9]' | grep -m 1 -o -e '[0-9]\+\.[0-9]\+\.[0-9]'
}

function nvim_install() {
    local download_dir='/tmp/nvim/'
    local filename="nvim-linux-x86_64.appimage"
    mkdir -p ${download_dir}

    cout info "Installing Neovim"
    download "https://github.com/neovim/neovim/releases/download/v$(nvim_latest_version)/${filename}" ${download_dir}
    sudo chmod +x ${download_dir}${filename}
    sudo chown $USER:$USER ${download_dir}${filename}

    if [[ -f /usr/bin/nvim ]]; then
        sudo rm /usr/bin/nvim
    fi

    sudo cp -f "${download_dir}${filename}" /usr/bin/nvim

    if [[ $? == 0 ]]; then
        cout success "NeoVim installed successfully."
        set_apt_hook nvim --update
    else
        cout error "Something went wrong."
    fi
}

function nvim_setup() {
    mkdir -p ~/.config/nvim/lua
    if [[ ! -d ~/.local/share/nvim/site/pack/packer/start/packer.nvim ]]
    then
        git clone --depth 1 https://github.com/wbthomason/packer.nvim\
            ~/.local/share/nvim/site/pack/packer/start/packer.nvim
    fi

    if [[ ! -h ~/.config/nvim/lua/plugins.lua ]]
    then
        ln -s ${MDS_CONFIG}/plugins.lua ~/.config/nvim/lua/plugins.lua
    fi

    if [[ ! -h ~/.config/nvim/lua/configs.lua ]]
    then
        ln -s ${MDS_CONFIG}/vim/lua/configs.lua ~/.config/nvim/lua/configs.lua
    fi

    echo "require('plugins')" > ~/.config/nvim/lua/init.lua
    echo "require('configs')" >> ~/.config/nvim/lua/init.lua

    echo "source \${MDS_CONFIG}/vimrc" > ~/.config/nvim/init.vim
    echo "lua require('init')" >> ~/.config/nvim/init.vim
}

function nvim_update() {
    if [[ ! -x "$(which nvim)" ]]
    then
        cout error "Nvim not installed"
    fi
    local latest_version=$(nvim_latest_version)
    local current_version=$(nvim -v | grep -m 1 -o -e '[0-9]\+\.[0-9]\+.[0-9]\+')
    if [[ "${current_version}" != "${latest_version}" ]]
    then
        nvim_install
    fi
}

OPTION=$1
: ${OPTION:="--install"}
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
