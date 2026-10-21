#!/bin/bash

source ${MDS_SCRIPTS}/common.sh

install_packages build-essential cmake libudev-dev qtbase5-dev zlib1g-dev libpulse-dev libquazip5-dev libqt5x11extras5-dev libxcb-screensaver0-dev libxcb-ewmh-dev libxcb1-dev qttools5-dev git libdbusmenu-qt5-dev

pushd ${GIT_REPOS} &> /dev/null
git clone https://github.com/ckb-next/ckb-next.git
pushd ckb-next &> /dev/null
./quickinstall
popd &> /dev/null
popd &> /dev/null
