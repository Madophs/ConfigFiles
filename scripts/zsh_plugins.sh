#!/usr/bin/env bash
if [[ ! -f $(which git) ]]; then
    echo "Error: git is not installed."
    exit 1
fi

if [[ ! -f $(which curl) ]]; then
    echo "Error: curl is not installed."
    exit 1
fi

curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
