#!/bin/bash

# Let' create file to store git token

if [[ $# < 1 ]]
then
    echo "[ERROR] Missing args"
    exit 1
fi

GITTOKEN=$MDS_CONFIG/token
create_token_file() {
    if [[ ! -f $GITTOKEN ]]
    then
        sudo touch $GITTOKEN && sudo chown root:root $GITTOKEN && sudo chmod 400 $GITTOKEN
        if [[ $? != 0 ]]; then
            echo "Wrong password"
            exit 0;
        fi
    else
        echo "[INFO] File already exists!"
    fi
}

delete_token_file() {
    sudo rm -f $GITTOKEN
    if [[ $? != 0 ]]
    then
        echo "Try again..."
        exit 0;
    fi
}

open_token_file() {
    if [[ -f $GITTOKEN ]]
    then
        sudo vim $GITTOKEN
    else
        echo "[ERROR] Git token file doesn't exists"
        exit 1
    fi
}

show_token() {
    if [[ -f $GITTOKEN ]]
    then
        sudo cat $GITTOKEN
    else
        echo "[ERROR] Git token file doesn't exists"
        exit 1
    fi
}

copy_token() {
    if [[ -f $GITTOKEN ]]
    then
        sudo xclip -selection clipboard $GITTOKEN
    else
        echo "[INFO] Git token file doesn't exists"
    fi
}

OPT=$1
main() {
    case $OPT in
        create)
            create_token_file
        ;;
        delete)
            delete_token_file
        ;;
        open)
            open_token_file
        ;;
        show)
            show_token
        ;;
        copy)
            copy_token
        ;;
    esac
}

main $OPT
