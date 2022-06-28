#!/bin/bash

assert_last_output() {
    RETVAL=$1
    MSG="Exiting"
    if [[ $# == 2 ]]
    then
        MSG=$2
    fi

    if [[ $RETVAL != 0 ]]
    then
        echo $MSG
        exit 1
    fi
}

CUDA_VERSION="11.7.0"
CUDA_DEB=$(ls -f cuda-repo*.deb 2> /dev/null)

if [[ -z $CUDA_DEB ]]
then
    echo "[WARNING] CUDA deb file not found."
    echo "Do do want to download it? (Y/N)"
    read OPT
    if [[ $OPT == "y" || $OPT == "Y" ]]
    then
        CUDA_DEB=cuda-repo-ubuntu2204-11-7-local_11.7.0-515.43.04-1_amd64.deb
        wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
        sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600
        wget https://developer.download.nvidia.com/compute/cuda/${CUDA_VERSION}/local_installers/$CUDA_DEB
        assert_last_output $? "[ERROR] Failed to download cuda"
    else
        echo "Exiting..."
        exit 0
    fi
fi

echo "[INFO] deb file: ${CUDA_DEB}"

sleep 2

echo "[INFO] Unholding nvidia packages..."
sudo apt-mark showhold | grep -i nvidia | xargs -L 1 sudo apt-mark unhold
sleep 3

echo "[INFO] Now let's upgrade..."
sudo apt update && sudo apt upgrade -y
sleep 3

echo "[WARNING] Purging cuda files."
sudo apt purge cuda\* -y
assert_last_output $? "[ERROR] Failed to purge cuda"

sleep 3
echo "[WARNING] Purging nvidia files."
sudo apt purge \*nvidia\* -y
assert_last_output $? "[ERROR] Failed to purge nvidia"
sleep 3

echo "[INFO] Installing nvidia driver."
sudo apt install nvidia-driver-510 -y
assert_last_output $? "[ERROR] Failed to install nvidia driver"
sleep 3

echo "[INFO] Installing Cuda ${CUDA_VERSION}"
sudo dpkg -i $CUDA_DEB
sudo cp /var/cuda-repo-ubuntu2204-11-7-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda

echo "[INFO] Holding nvidia libs(i:386) for steam compatibility"
sudo apt update
apt list --upgradable | grep nvidia | awk -F '/' '{print $1}' | xargs -L 1 sudo apt-mark hold
echo "[SUCCESS] Ready to go."
