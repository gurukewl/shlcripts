#!/bin/bash
#
#
clear

echo " "
echo "*****************************************************"
echo " This script will set up a qbittorrent-nox, samba"
echo "*****************************************************"

sudo apt install ntfs-3g -y
sudo mkdir /media/NASDRIVE
sudo chmod 770 /media/NASDRIVE

echo " "
echo "****************************************************************"
echo "Please enter the data path you would like to use"
echo "****************************************************************"
read d

apt update
apt upgrade -y
sudo apt install qbittorrent-nox samba samba-common-bin -y

cat <<EOF >> /etc/samba/smb.conf
[NASDrive]
comment = NASDRIVE
path = /media/NASDRIVE
available = yes
valid users = root
#force group = users
#create mask = 0660
#directory mask = 0771
read only = no
public = yes
writable = yes
EOF

echo " "
echo "***************************************************************"
echo "SAMBA configuation updated"
echo "---------------------------------------------------------------"

clear

echo " "
echo "***************************************************************"
echo "YOU WILL NOW BE ASKED TO ENTER A PASSWORD FOR YOUR SAMBA USER"
echo "---------------------------------------------------------------"
echo " "
echo " Please enter a password when prompted, this needs to be remembered"
echo " "
echo "********************************************************************"

sudo smbpasswd -a root
clear

echo "INSTALLING QBITTORRENT-DAEMON"

sudo mv qbittorrent-nox-daemon  /etc/init.d/qbittorrent-nox-daemon
sudo chmod 755 /etc/init.d/qbittorrent-nox-daemon
sudo update-rc.d qbittorrent-nox-daemon defaults

clear

sudo mkdir -p $d/Completed
sudo mkdir -p $d/Incomplete

echo " "
echo "*****************************************************"
echo "THE INSTALLATION HAS FINSIHED"
echo "-----------------------------------------------------"
echo " "
echo " Please configure QBITTORRENT and then access via IP:8080 in your browser"
echo " "
echo "**************************************************************************************************************"
