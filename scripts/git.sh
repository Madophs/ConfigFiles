#!/bin/bash

if [[ $# == 0 ]]
then
    echo "[INFO] Invalid params. Params: clone [repo], push, fetch."
    exit 0
fi

TOKEN=$($MDS_CONFIG/scripts/handle_git_token.sh show)

if [[ $? != 0 || -z $TOKEN ]]
then
    echo "[ERROR] Make sure that you have a token."
    exit 1
fi

is_git_repo() {
    git status &> /dev/null
    if [[ $? != 0 ]]
    then
        echo "[ERROR] Not a git repo."
        exit 1
    fi
}

####    MAIN    ####
case $1 in
    push)
        is_git_repo
        $MDS_CONFIG/scripts/git_expect.exp ${TOKEN} push
    ;;
    clone)
        if [[ $# != 2 ]]; then echo "[ERROR] Need to specify a repo."; exit 1; fi;
        REPO=$2
        $MDS_CONFIG/scripts/git_expect.exp ${TOKEN} clone $REPO
    ;;
    fetch)
        is_git_repo
        $MDS_CONFIG/scripts/git_expect.exp ${TOKEN} fetch
    ;;
    *)
        echo -n "[ERROR] Unknown option."
    ;;
esac
