#!/bin/bash

source ${MDS_SCRIPTS}/common.sh

declare -g deps=(cmake vifm axel curl xclip xorg-dev ripgrep python3 python3-pip pipx clang clangd clang-17 clangd-17 \
    python3-neovim python3-full python3-dev lua5.4 luarocks htop)

declare -g python_modules=(wpm neovim-remote)

for item in ${deps[@]}
do
    install_package_if_missing ${item} NO
done

for item in ${python_modules[@]}
do
    pipx install ${item}
done
