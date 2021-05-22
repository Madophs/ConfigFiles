#!/bin/bash

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

git_push
