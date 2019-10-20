#!/bin/bash
#
pwd
read d
cd
clear

echo " "
echo "*****************************************************"
echo " This script will set up a cloud9 IDE  on your target server"
echo "-----------------------------------------------------"
echo "Please enter the data path you would like to use to access Cloud9?"
echo "****************************************************************"
read wd

sudo apt update
#apt-get upgrade -y

clear

echo " "
echo "***************************************************************"
echo "INSTALLING CLOUD9"
echo "---------------------------------------------------------------"

sudo apt-get install curl software-properties-common tmux -y

curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -

export LANG=en_US.UTF-8
export LANGUAGE=en:el

sudo apt install git nodejs -y

git clone https://github.com/c9/core.git c9sdk

cd c9sdk

sudo ./scripts/install-sdk.sh

echo " "
echo "***************************************************************"
echo "INSTALLING CLOUD9-DAEMON"
echo "---------------------------------------------------------------"

sudo mv $d/cloud9-daemon /etc/init.d/cloud9-daemon
sudo chmod 755 /etc/init.d/cloud9-daemon
sudo update-rc.d cloud9-daemon defaults
sudo mkdir -p $wd/workspace

clear

echo " "
echo "*****************************************************"
echo "THE INSTALLATION HAS FINSIHED"
echo "-----------------------------------------------------"
echo " Please browse to your IP:8181 in your browser to access cloud9"
echo "**************************************************************************************************************"
