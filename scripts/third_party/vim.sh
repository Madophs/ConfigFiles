#!/bin/bash

source $MDS_SCRIPTS/common.sh

install_packages git python3-distutils-extra python3-dev libncurses-dev
cd $GIT_REPOS

CPUs=$(( ($(lscpu -p | tail -n 1 | awk -F ',' '{ print $1 }') + 1) / 2 ))

PYTHON_VERSION=$(python3 --version)
if [[ -d vim ]]
then
    cd vim
    git fetch --all
    git pull
    make distclean
    ./configure --prefix=/usr/local \
        --enable-python3interp \
        --with-x \
        --with-python3-config-dir=/usr/lib/${PYTHON_VERSION}/config-*
else
    git clone https://github.com/vim/vim.git
    cd vim
    ./configure --prefix=/usr/local \
        --enable-python3interp \
        --with-x \
        --with-python3-config-dir=/usr/lib/${PYTHON_VERSION}/config-*
fi

cd src
make -j $CPUs
sudo make install

if [[ ! -f ${HOME}/.vimrc ]]
then
    echo "source ${GIT_REPOS}/ConfigFiles/vimrc" > ${HOME}/.vimrc
fi
