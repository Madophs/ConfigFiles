#!/usr/bin/env bash

update_git_plugin() {
    missing_argument_validation 1 $@

    local plugin_path=${1}
    if [[ ! -d ${plugin_path} ]]; then
        echo "Error: directory ${plugin_path} doesn't exists."
    fi

    if [[ -d ${plugin_path}/.git ]]; then
    pushd ${plugin_path}
    git fetch --all
    git pull
    else
        echo "Error: ${plugin_path} not a git repo."
    fi
}

#handle_plugins $git_repo $plugin_path $plugin_name $enabled (Y/N)
handle_zsh_plugin() {
    missing_argument_validation 4 $@

    local git_repo=$1
    local plugin_path=$2
    local plugin_name=$3
    local enabled=$4

    if [[ ${enabled} == "Y" ]]; then
        if [[ ! -e ${plugin_path} ]]; then
            git clone ${git_repo} ${plugin_path}
        else
            cout info "${plugin_name} its already installed."
            cout info "Upgrading..."
            update_git_plugin ${plugin_path}
        fi
    elif [[ ${enabled} == "N" ]]; then
        if [[ -e ${plugin_path} ]]; then
            cout warning "Removing ${plugin_name} plugin..."
            rm -rf ${plugin_path}
            cout info "Plugin removed."
        fi
    else
        cout error "Invalid argument ${enabled}"
    fi
}
