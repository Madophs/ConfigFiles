#!/bin/bash

# This scripts installs ACE framework

DOWNLOAD_LINK='https://github.com/DOCGroup/ACE_TAO/releases/download/ACE%2BTAO-7_0_2/ACE+TAO-7.0.2.tar.gz'
ACE_FILE='ACE+TAO-7.0.2.tar.gz'

mkdir -p $MDS_APPS
cd $MDS_APPS

if [[ ! -f $ACE_FILE ]]
then
    axel -a $DOWNLOAD_LINK
else
    echo "[INFO] ACE tar file already found."
fi

# Check if ACE tar file is already uncompressed
if [[ ! -d ACE_wrappers ]]
then
    echo "[INFO] Uncompressing ACE source code..."
    sleep 1
    tar -xf $ACE_FILE
    echo "[INFO] Proceeding with the building stage..."
else
    echo "[INFO] ACE source code found proceeding with the building stage."
fi

echo "[INFO] Installing required dependencies"
sudo apt install libfl-dev cmake make build-essential libfltk1.1-dev libx11-dev libgl-dev libtk-img-dev libssl-dev

# ACE source code
cd ACE_wrappers
export ACE_ROOT=$(pwd)

# Move to ace directory, I just want to build ACE not the test cases.
cd ace

echo '#include "ace/config-linux.h"' > $ACE_ROOT/ace/config.h
echo 'include $(ACE_ROOT)/include/makeinclude/platform_linux.GNU' > $ACE_ROOT/include/makeinclude/platform_macros.GNU
echo 'INSTALL_PREFIX = /usr/local' >> $ACE_ROOT/include/makeinclude/platform_macros.GNU
export LD_LIBRARY_PATH=$ACE_ROOT/lib:$LD_LIBRARY_PATH

# When all this is done, hopefully all you'll need to do is type. (It's what they say haha)

CPUs=$(( ($(lscpu -p | tail -n 1 | awk -F ',' '{ print $1 }') + 1) / 2 ))
echo "[INFO] Using $CPUs CPUs for the build."
sleep 2
make -j $CPUs wfmo=1 x11=1 gl=1 fl=1 xt=1 ssl=1 tk=1
su -c 'export ACE_ROOT=$ACE_ROOT; cd $ACE_ROOT/ace; make install wfmo=1 x11=1 gl=1 fl=1 xt=1 ssl=1 tk=1' root
echo "[SUCCESS] ACE Framework successfully installed."
