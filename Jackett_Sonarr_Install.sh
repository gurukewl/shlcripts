#!/bin/bash
#
clear
echo " "
echo "*****************************************************"
echo "WELCOME TO THE NEXTCLOUD INSTALLATION SCRIPT"
echo "-----------------------------------------------------"
echo " This script will set up a ownCloud storage server on your target server"
echo "*****************************************************"

clear
cd 

#Ubuntu-Install
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb http://download.mono-project.com/repo/ubuntu xenial main" | sudo tee /etc/apt/sources.list.d/mono-official.list
sudo apt update

#Debian-Install
#sudo apt install ca-certificates apt-transport-https -y
#wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add -
#echo "deb https://packages.sury.org/php/ stretch main" | sudo tee /etc/apt/sources.list.d/php.list

cd /opt
wget http://update.sonarr.tv/v2/master/mono/NzbDrone.master.tar.gz
sudo tar -xf NzbDrone* 

mv sonarr.service /etc/systemd/system/sonarr.service
sudo systemctl enable /etc/systemd/system/sonarr.service
sudo service sonarr start

clear

echo " "
echo "*****************************************************"
echo "THE INSTALLATION HAS FINSIHED"
echo "-----------------------------------------------------"
echo " Please browse to your IP:8989 in your browser to access Sonarr"
echo "**************************************************************************************************************"
