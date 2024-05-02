#!/bin/bash

source ${MDS_SCRIPTS}/common.sh
missing_argument_validation 1 $1

GITTOKEN=${MDS_HIDDEN_CONFIGS}/token
create_token_file() {
    if [[ ! -f ${GITTOKEN} ]]
    then
        sudo touch ${GITTOKEN} && sudo chown root:root ${GITTOKEN} && sudo chmod 600 ${GITTOKEN} && sudo chattr +i ${GITTOKEN}
        if [[ $? != 0 ]]; then
            cout error "Wrong password"
        fi
    else
        cout warning "File already exists!"
        cout info "Replace? (y/n)"
        read opt
        if [[ ${opt} == 'y' ]]
        then
            sudo chattr -i ${GITTOKEN} && sudo rm -f ${GITTOKEN}
            sudo touch ${GITTOKEN} && sudo chown root:root ${GITTOKEN} && sudo chmod 600 ${GITTOKEN} && sudo chattr +i ${GITTOKEN}
        fi
    fi
}

delete_token_file() {
    sudo rm -f ${GITTOKEN}
    if [[ $? != 0 ]]
    then
        cout warning "Try again..."
    fi
}

open_token_file() {
    if [[ -f ${GITTOKEN} ]]
    then
        sudo chattr -i ${GITTOKEN}
        sudo vim --cmd noswapfile ${GITTOKEN}
        sudo chattr +i ${GITTOKEN}
    else
        cout error "Git token file doesn't exists"
    fi
}

show_token() {
    if [[ -f ${GITTOKEN} ]]
    then
        sudo cat ${GITTOKEN}
    else
        cout error "Git token file doesn't exists"
    fi
}

copy_token() {
    if [[ -f ${GITTOKEN} ]]
    then
        sudo xclip -selection clipboard ${GITTOKEN}
    else
        cout info "Git token file doesn't exists"
    fi
}

OPT=$1
main() {
    case ${OPT} in
        create)
            create_token_file
        ;;
        delete)
            delete_token_file
        ;;
        open|edit)
            open_token_file
        ;;
        show)
            show_token
        ;;
        copy)
            copy_token
        ;;
        *)
            cout info "options {create|delete|open|edit|show|copy}"
        ;;
    esac
}

main ${OPT}
