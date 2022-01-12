#!/bin/bash

source $MDS_SCRIPTS/common.sh

install_packages git python3-distutils python3-dev python2-dev
CURRDIR=$(pwd)
cd $GIT_REPOS

CPUs=$(( ($(lscpu -p | tail -n 1 | awk -F ',' '{ print $1 }') + 1) / 2 ))

PYTHON_VERSION=$(python3 --version)
if [[ -d vim ]];
then
    cd vim
    git fetch --all
    git pull
    make distclean
    ./configure --prefix=/usr/local \
        --enable-python3interp \
        --with-python3-config-dir=/usr/lib/${PYTHON_VERSION}/config-*
    cd src
    make -j $CPUs
else
    git clone https://github.com/vim/vim.git
    cd vim
    ./configure --prefix=/usr/local \
        --enable-python3interp \
        --with-python3-config-dir=/usr/lib/${PYTHON_VERSION}/config-*
    cd src
    make -j $CPUs
fi

sudo make install
