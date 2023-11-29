#!/bin/bash

source ${MDS_SCRIPTS}/common.sh

function nvim_install() {
    local download_dir='/tmp/nvim/'
    mkdir -p ${download_dir}

    cout info "Installing Neovim"
    download https://github.com/neovim/neovim/releases/latest/download/nvim.appimage  ${download_dir}
    sudo chmod +x ${download_dir}nvim.appimage
    sudo chown $USER:$USER ${download_dir}nvim.appimage

    if [[ -f /usr/bin/nvim ]]; then
        sudo rm /usr/bin/nvim
    fi

    sudo cp -f ${download_dir}nvim.appimage /usr/bin/nvim

    if [[ $? == 0 ]]; then
        cout success "NeoVim installed successfully."
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

OPTION=$1
: ${OPTION:="--install"}
case ${OPTION} in
    --install)
        nvim_install
    ;;
    --setup)
        nvim_setup
    ;;
esac

