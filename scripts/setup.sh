#!/usr/bin/env bash

FILE_PATH=$HOME/Documents/git/ConfigFiles/.path.txt
if [[ ! -e  $FILE_PATH ]]; then
    touch $FILE_PATH
fi

# Nice looking file listing
# Credits: https://github.com/Peltoche/lsd
if [[ -f $(which lsd) ]]; then
    alias ls='lsd'
    alias ll='ls -l'
    alias la='ls -a'
    alias lla='ls -la'
    alias lt='ls --tree'
fi
