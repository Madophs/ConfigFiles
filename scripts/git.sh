#!/bin/bash

source "${MDS_SCRIPTS}/utils/cout.sh"

if (( $# == 0 ))
then
    cout fail "Invalid params. Params: clone [repo], push, fetch, pull."
fi

TOKEN=$(gtoken show)

if [[ $? != 0 || -z ${TOKEN} ]]
then
    cout fail "Make sure that you have a token."
fi

function is_git_repo() {
    if ! git status &> /dev/null;
    then
        cout fail "Not a git repo"
    fi
}

####    MAIN    ####
case $1 in
    push)
        is_git_repo
        shift
        "${MDS_CONFIG}/scripts/git_expect.exp" "${TOKEN}" push "$@"
    ;;
    pull)
        is_git_repo
        "${MDS_CONFIG}/scripts/git_expect.exp" "${TOKEN}" pull
    ;;
    clone)
        (( $# != 2 )) && cout error "Need to specify a repository."
        REPO=$2
        "${MDS_CONFIG}/scripts/git_expect.exp" "${TOKEN}" clone "${REPO}"
    ;;
    fetch)
        is_git_repo
        "${MDS_CONFIG}/scripts/git_expect.exp" "${TOKEN}" fetch
    ;;
    *)
        cout error "Unknown options."
    ;;
esac
