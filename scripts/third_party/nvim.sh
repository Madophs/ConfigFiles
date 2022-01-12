#!/bin/bash

echo '[INFO] Intalling NeoVim'
DOWNLOAD_DIR='/tmp/nvim/'
mkdir -p ${DOWNLOAD_DIR}

axel -a https://github.com/neovim/neovim/releases/latest/download/nvim.appimage -o ${DOWNLOAD_DIR}
sudo chmod +x ${DOWNLOAD_DIR}nvim.appimage
sudo chown $USER:$USER ${DOWNLOAD_DIR}nvim.appimage

if [[ -f /usr/bin/nvim ]]; then
    sudo rm /usr/bin/nvim
fi

sudo cp -f ${DOWNLOAD_DIR}nvim.appimage /usr/bin/nvim

if [[ $? == 0 ]]; then
    echo '[SUCCESS] NeoVim installed successfully.'
else
    echo '[ERROR] Something went wrong.'
fi
