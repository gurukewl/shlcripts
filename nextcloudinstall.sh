#!/bin/bash
#
clear

echo " "
echo "*****************************************************"
echo "WELCOME TO THE NEXTCLOUD INSTALLATION SCRIPT"
echo "-----------------------------------------------------"
echo " "
echo " This script will set up a ownCloud storage server on your target server"
echo " "
echo "*****************************************************"

clear

echo " "
echo "****************************************************************"
echo "Please enter the data path you would like to use to access nextCloud"
echo "****************************************************************"
read d

clear

apt update
#apt upgrade -y

#Ubuntu-Install
apt install software-properties-common -y
add-apt-repository ppa:ondrej/php

#Debian-Install
sudo apt install ca-certificates apt-transport-https -y
wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add -
echo "deb https://packages.sury.org/php/ stretch main" | sudo tee /etc/apt/sources.list.d/php.list

apt update
clear
sudo apt install apache2 -y

sudo apt install php7.2 php7.2-gd sqlite php7.2-sqlite3 php7.2-curl php7.2-zip php7.2-xml php7.2-mbstring -y

sudo service apache2 restart

cd /var/www/html

curl https://download.nextcloud.com/server/releases/nextcloud-17.0.0.tar.bz2 | sudo tar -jxv

sudo mkdir -p $d/nextcloud/data
sudo chown www-data:www-data /var/www/html/nextcloud/ -R
sudo chown www-data:www-data $d/nextcloud/data -R
#sudo chmod 750 $d/nextcloud/data

clear

echo " "
echo "*****************************************************"
echo "THE INSTALLATION HAS FINSIHED"
echo "-----------------------------------------------------"
echo " "
echo " Please browse to your IP/nextcloud in your browser to access nextCloud"
echo " "
echo "**************************************************************************************************************"
