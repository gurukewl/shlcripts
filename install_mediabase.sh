#!/bin/bash

echo "This script installs Max2Play-Scripts to /opt/max2play and the webinterface to /var/www/max2play"
echo " - On first start it will do an update/upgrade and expand filesystem and get Max2Play files - then it automatically rebootes"
echo " - On second start it installs all the fancy stuff and brings the webinterface to life"
echo "Depending on the system (ODROID/PI) and Linux Version (Debian/Ubuntu) it installs or compiles differents packages and its dependencies like squeezelite, Kodi, shairport, samba, etc." 
echo "Edit Parameters on top of script to change the default behavior of this script!"
echo ""
echo "Add Execute rights with 'chmod 777 install_max2play.sh'"
echo "RUN with 'sudo install_max2play.sh 2>&1 | tee install_max2play.log' to save Install-Logfile and see output on console!"
echo ""

# expand Filesystem during install
EXPAND_FILESYSTEM="N"

# set to Y if you want default password "max2play"
CHANGE_PASSWORD="N" 

# leave empty to keep current hostname
CHANGE_HOSTNAME="NAS@Server" 
PROJECT="max2play" #, max2play, squeezeplug, hifiberry, etc.

CWD=$(pwd)

if [ "$(whoami)" != "root" ]; then
	echo "Run this script with sudo OR as root! Otherwise it won't install correctly!"
	exit 1
fi

LINUX=$(lsb_release -a 2>/dev/null | grep Distributor | sed "s/Distributor ID:\t//")
RELEASE=$(lsb_release -a 2>/dev/null | grep Codename | sed "s/Codename:\t//")

echo "Linux is $LINUX"
echo "Release is $RELEASE"
  
FREESPACE=$(df -km | grep /dev/root | tail -1 | awk '{print $4}')
if [ "$FREESPACE" -lt "500" ]; then
 	echo "Only $FREESPACE MB memory available - Expand filesystem manually and Reboot!"
  	exit 1
fi  


git clone https://github.com/coolsdaks/MediaBase.git
unzip max2play_base.zip -d max2play
mkdir /opt
sudo cp -r max2play/opt/* /opt
chmod -R 777 /opt/max2play/

# chmod 666 /etc/fstab
# echo -e "\n##USERMOUNT" >> /etc/fstab
# cp /etc/fstab /etc/fstab.sav
# chmod 666 /etc/fstab.sav

if [ "$LINUX" == "Ubuntu" ]; then
	sudo echo "Y" | apt-get install apache2 php libapache2-mod-php php7.0-xml -y
	# Make sure eth0 is named correctly	
	sudo echo 'SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="*", ATTR{dev_id}=="0x0", ATTR{type}=="1", KERNEL=="eth*", NAME="eth0"' >> /etc/udev/rules.d/70-persistent-net.rules
else [ "$LINUX" == "Debian" ]; then
	sudo echo "Y" | apt-get install apache2 php php-json php-xml -y
fi

sudo a2enmod rewrite
rm /etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-enabled/000-default
cp max2play/CONFIG_SYSTEM/apache2/sites-enabled/max2play.conf /etc/apache2/sites-enabled/
sed -i 's/LogLevel warn/LogLevel error/' /etc/apache2/apache2.conf
cp -r max2play/max2play/ /var/www/max2play 
sudo /etc/init.d/apache2 restart
sudo echo "Y" | apt-get install samba samba-common samba-common-bin mc ntfs-3g cifs-utils nfs-common git libconfig-dev smbclient

sudo apt-get install debconf-utils
  	echo "Generate Locales for predefined languages..."
  	sed -i 's/# en_US.UTF-8 UTF-8/' /etc/locale.gen
  	locale-gen

export LANG=en_US.UTF-8
dpkg-reconfigure -f noninteractive locales
echo "Asia/Kolkata" > /etc/timezone
ln -fs /usr/share/zoneinfo/`cat /etc/timezone` /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

# HD-Idle aktivieren
# dpkg -i max2play/hd-idle_1.05_armhf.deb
# sudo sed -i 's/START_HD_IDLE=.*/START_HD_IDLE=true/' /etc/default/hd-idle

sudo echo "Y" | apt-get install usbmount
cp -f max2play/CONFIG_SYSTEM/usbmount/usbmount.conf /etc/usbmount/usbmount.conf

# #fix exzessives Logging in syslog & co (cron)
cp -f max2play/CONFIG_SYSTEM/rsyslog.conf /etc/rsyslog.conf

# #Copy Config Files / Update Max2Play einmalig nötig
echo "1.0" > /var/www/max2play/application/config/version.txt


pushd $CWD
#Sudoers
cp -f max2play/CONFIG_SYSTEM/sudoers.d/max2play /etc/sudoers.d/
#Network
cp -f max2play/CONFIG_SYSTEM/network/* /etc/network/
chmod 666 /etc/network/*
#Samba
cp -f max2play/CONFIG_SYSTEM/samba/smb.conf /etc/samba/
#Udev Rules
cp -f max2play/CONFIG_SYSTEM/udev/rules.d/* /etc/udev/rules.d/

#Add Net-Availability Check for Mountpoints to /etc/rc.local and make it more robust with "set +e"
sudo sed -i "s/^exit 0/#Network Check for Mountpoints\nCOUNTER=0;while \[ -z \"\$\(\/sbin\/ip addr show eth0 \| grep -i 'inet '\)\" -a -z \"\$\(\/sbin\/ip addr show wlan0 \| grep -i 'inet '\)\" -a \"\$COUNTER\" -lt \"5\" \]; do echo \"Waiting for network\";COUNTER=\$\(\(COUNTER+1\)\);sleep 3;done;set +e;\/bin\/mount -a;set -e;\n\nexit 0/" /etc/rc.local

if [ "$CHANGE_HOSTNAME" = "" ]; then
 	cat /etc/hostname > /opt/max2play/playername.txt
 	cat /etc/hostname > /opt/max2play/playername.txt.sav
else
 	echo "$CHANGE_HOSTNAME" > /etc/hostname
 	# edit hosts file
 	sudo sed -i "s/raspberrypi/$CHANGE_HOSTNAME/;s/odroid/$CHANGE_HOSTNAME/" /etc/hosts
fi
chmod 666 /etc/hostname

chmod 777 /opt/max2play/wpa_supplicant.conf

echo "To Install Autoconfig run: "
echo "sed -i \"s@^#Max2Play\\\$@#Max2Play\nif [ -e /boot/max2play.conf ]; then /opt/max2play/autoconfig.sh; fi\n@\" /etc/rc.local" 

#Remove Install Files in local directory
# rm -R max2play
# rm -R max2play_complete.zip
# rm install_max2play.sh

#Remove Bash history & Clean up the system
apt-get --yes autoremove
apt-get --yes autoclean
apt-get --yes clean
rm /root/.bash_history
cd /
history -c
