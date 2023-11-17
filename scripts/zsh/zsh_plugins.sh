#!/bin/env zsh

if [[ -e ${ZSH_CUSTOM}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source ${ZSH_CUSTOM}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [[ -e ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

if [[ -e ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-navigation-tools/zsh-navigation-tools.plugin.zsh ]]; then
    source ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-navigation-tools/zsh-navigation-tools.plugin.zsh
    znt_list_instant_select=1
    znt_list_border=0
    znt_list_bold=1
    znt_list_colorpair="green/black"
    znt_functions_keywords=( "zplg" "zgen" "match"  )
    znt_cd_active_text="underline"
    znt_env_nlist_coloring_color=$'\x1b[00;33m'
    znt_cd_hotlist=( "~/.config/znt" "/usr/share/zsh/site-functions" "/usr/share/zsh"
                    "/usr/local/share/zsh/site-functions" "/usr/local/share/zsh"
                                    "/usr/local/bin" )

    source ${MDS_SCRIPTS}/zsh/hotlist.sh
    load_hostlist_file
fi
