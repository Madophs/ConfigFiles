#!/bin/bash

if [[ $# > 1 ]]
then
    echo "Too many arguments..."
    exit 1
fi

# Good for public repos
git_push() {
    git rev-parse --show-toplevel &> /dev/null
    if [[ $? == 0 ]]
    then
        REPO=$(git remote show origin | grep 'Push  URL' | awk -F '//' '{print $NF}')
        TOKEN=$($MDS_CONFIG/scripts/handle_git_token.sh show)
        git push https://madophs:${TOKEN}@${REPO}
    else
        echo "[INFO] Not a git repository."
        exit 1
    fi
}

# Good for push to remote private repos
git_push_force() {
    git status &> /dev/null
    if [[ $? == 0 ]]
    then
        TOKEN=$($MDS_CONFIG/scripts/handle_git_token.sh show)
        $MDS_CONFIG/scripts/git_push_expect.exp ${TOKEN}
    else
        echo "[ERROR] Not a git repo."
        exit 1
    fi
}

if [[ $# == 1 ]]
then
    case $1 in
        force)
            git_push_force
        ;;
        *)
            echo -n "[ERROR] Unknown option."
        ;;
    esac
else
    git_push
fi

