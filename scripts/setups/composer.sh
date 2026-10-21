#!/bin/bash

function composer_install() {
    local tmpdir=/tmp/composer
    local install_dir=${HOME}/.local/bin
    mkdir -p ${tmpdir}
    pushd ${tmpdir} &> /dev/null
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php composer-setup.php --install-dir=${install_dir} --filename=composer
    php -r "unlink('composer-setup.php');"
    popd &> /dev/null
}
