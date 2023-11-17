#!/bin/bash

source ${MDS_SCRIPTS}/common.sh
source ${MDS_SCRIPTS}/zsh/plugins_enabled_default.sh
source ${MDS_SCRIPTS}/zsh/update_git_plugin.sh

# User configs (overrides default ones)
if [[ -f ${MDS_HIDDEN_CONFIGS}/plugins_enabled_user.sh ]]; then
    source ${MDS_HIDDEN_CONFIGS}/plugins_enabled_user.sh
fi

install_cmd_if_missing git
install_cmd_if_missing curl

if [[ ! -e ~/.vim/autoload/plug.vim ]]; then
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
    cout info "Plug plugin its already installed."
fi

handle_zsh_plugin https://github.com/zsh-users/zsh-autosuggestions \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    zsh-autosuggestions \
    ${ZSH_AUTOSUGGESTIONS_ENABLED}

handle_zsh_plugin https://github.com/zsh-users/zsh-syntax-highlighting.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    zsh-syntax-highlighting \
    ${ZSH_SYNTAX_HIGHLIGHTING_ENABLED}

handle_zsh_plugin https://github.com/psprint/zsh-navigation-tools.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-navigation-tools \
    zsh-navigation-tools \
    ${ZSH_NAVIGATION_TOOLS_ENABLED}

