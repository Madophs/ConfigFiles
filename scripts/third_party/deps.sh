#!/bin/bash

source ${MDS_SCRIPTS}/common.sh

declare -g deps=(cmake vifm axel curl xclip xorg-dev ripgrep python3 python3-pip pipx clang clangd clang-17 clangd-17 \
    python3-neovim python3-full python3-dev lua5.4 luarocks htop expect genius gnome-calculator bat universal-ctags cscope valgrind\
    nasm calibre vlc \
    php8.2 php8.2-odbc php8.2-bcmath php8.2-cgi php8.2-cli php8.2-curl php8.2-common php8.2-gd php8.2-gmagick php8.2-http php8.2-imap php8.2-mbstring php8.2-mysql php8.2-pgsql php8.2-snmp php8.2-soap php8.2-sqlite3 php8.2-xml php8.2-yaml php8.2-raphf nginx \
    )

declare -g python_modules=(wpm neovim-remote)

for item in ${deps[@]}
do
    install_package_if_missing ${item} NO
    sleep 0.2
done

for item in ${python_modules[@]}
do
    pipx install ${item}
done
