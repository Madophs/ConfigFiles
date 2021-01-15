#!/usr/bin/env bash
if [[ ! -f $(which git) ]]; then
    echo "Error: git is not installed."
    exit 1
fi

if [[ ! -f $(which curl) ]]; then
    echo "Error: curl is not installed."
    exit 1
fi

if [[ ! -e ~/.vim/autoload/plug.vim ]]; then
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
    echo "INFO: plug plugin its already installed."
fi

. $MDS_CONFIG/scripts/update_git_plugin.sh

handle_zsh_plugin https://github.com/zsh-users/zsh-autosuggestions \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    zsh-autosuggestions \
    $ZSH_AUTOSUGGESTIONS_ENABLED

handle_zsh_plugin https://github.com/zsh-users/zsh-syntax-highlighting.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    zsh-syntax-highlighting \
    $ZSH_SYNTAX_HIGHLIGHTING_ENABLED

handle_zsh_plugin https://github.com/psprint/zsh-navigation-tools.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-navigation-tools \
    zsh-navigation-tools \
    $ZSH_NAVIGATION_TOOLS_ENABLED
