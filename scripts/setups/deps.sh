#!/bin/bash

source ${MDS_SCRIPTS}/common.sh

declare -g deps=(cmake vifm axel curl xclip xorg-dev ripgrep python3 python3-pip pipx clang clangd clang-17 clangd-17 \
    python3-pynvim python3-full python3-dev lua5.4 luarocks htop expect genius gnome-calculator bat universal-ctags cscope valgrind \
    nasm xbanish calibre vlc radare2 fzf zoxide autojump highlight mpv inxi mcomix unrar dict pulseaudio-module-bluetooth sox libsox-fmt-mp3 \
    php8.3 php8.3-odbc php8.3-bcmath php8.3-cgi php8.3-cli php8.3-curl php8.3-common php8.3-gd php8.3-gmagick php8.3-http php8.3-imap php8.3-mbstring php8.3-mysql php8.3-pgsql php8.3-snmp php8.3-soap php8.3-sqlite3 php8.3-xml php8.3-yaml php8.3-raphf php8.3-zip php8.3-fpm nginx \
    lynx \
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
