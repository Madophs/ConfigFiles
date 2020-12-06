#!/usr/bin/env bash

FILE_PATH=$HOME/Documents/git/ConfigFiles/.path.txt
if [[ ! -e  $FILE_PATH ]]; then
    touch $FILE_PATH
fi
