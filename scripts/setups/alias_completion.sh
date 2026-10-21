#!/bin/bash

function bc_install() {
    local directory="${GIT_REPOS}/alias_completion"
    if [[ ! -d ${directory} ]]
    then
        mkdir -p "${directory}"
        git clone https://github.com/cykerway/complete-alias.git "${GIT_REPOS}/alias_completion"
    else
        cd "${directory}"
        git fetch && git pull
    fi
}

bc_install
