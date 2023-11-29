#!/bin/bash

source ${MDS_SCRIPTS}/common.sh

if [[ $# == 0 ]]
then
    cout error "Invalid params. Params: clone [repo], push, fetch, pull."
fi

TOKEN=$(${MDS_CONFIG}/scripts/handle_git_token.sh show)

if [[ $? != 0 || -z ${TOKEN} ]]
then
    cout error "Make sure that you have a token."
fi

is_git_repo() {
    git status &> /dev/null
    if [[ $? != 0 ]]
    then
        cout error "Not a git repo"
    fi
}

####    MAIN    ####
case $1 in
    push)
        is_git_repo
        shift
        ${MDS_CONFIG}/scripts/git_expect.exp ${TOKEN} push "$@"
    ;;
    pull)
        is_git_repo
        ${MDS_CONFIG}/scripts/git_expect.exp ${TOKEN} pull
    ;;
    clone)
        if [[ $# != 2 ]]; then echo "[ERROR] Need to specify a repo."; exit 1; fi;
        REPO=$2
        ${MDS_CONFIG}/scripts/git_expect.exp ${TOKEN} clone ${REPO}
    ;;
    fetch)
        is_git_repo
        ${MDS_CONFIG}/scripts/git_expect.exp ${TOKEN} fetch
    ;;
    *)
        cout error "Unknown options."
    ;;
esac
