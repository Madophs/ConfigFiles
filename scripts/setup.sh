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

# Let's ignore some common commands of being registered from history
zshaddhistory() {
    # Get the command the remove the carriage return
    INPUT_COMMAND=${1%$'\n'}
    case $INPUT_COMMAND in
        ls|ls\ *|ll|ls\ *)
            return 1
            ;;
        clear)
            return 1
            ;;
        cd)
            return 1
            ;;
        loadsh|setroot)
            return 1;
    esac
    return 0;
}
