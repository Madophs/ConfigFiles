#!/usr/bin/env bash

update_git_plugin() {
    if [[ (( $# < 1 )) ]]; then
        echo "Error: missing arguments."
        exit 1
    elif [[ (( $# > 1 )) ]]; then
        echo "Error: too many arguments."
        exit 1
    fi

    PLUGIN_PATH=$1

    if [[ ! -d $PLUGIN_PATH ]]; then
        echo "Error: directory doesn't exists."
        exit 1
    fi

    if [[ -d $PLUGIN_PATH/.git ]]; then
    pushd $PLUGIN_PATH
    git fetch --all
    git pull
    else
        echo "Error: ${PLUGIN_PATH} not a git repo."
    fi
}

#handle_plugins $GIT_REPO $PLUGIN_PATH $PLUGIN_NAME $ENABLED (Y/N)
handle_zsh_plugin() {
    if [[ $# <  3 ]]; then
        echo "Error: handle_plugins missing arguments."
        exit 1
    fi

    GIT_REPO=$1
    PLUGIN_PATH=$2
    PLUGIN_NAME=$3
    ENABLED=$4

    if [[ $ENABLED == "Y" ]]; then
        if [[ ! -e $PLUGIN_PATH ]]; then
            git clone $GIT_REPO $PLUGIN_PATH
        else
            echo "INFO: ${PLUGIN_NAME} its already installed."
            echo "Upgrading..."
            update_git_plugin $PLUGIN_PATH
        fi
    elif [[ $ENABLED == "N" ]]; then
        if [[ -e $PLUGIN_PATH ]]; then
            echo "Removing ${PLUGIN_NAME} plugin..."
            rm -rf $PLUGIN_PATH
            echo "Plugin removed."
        fi
    else
        echo "Error: Invalid argument ${ENABLED}"
    fi
}
