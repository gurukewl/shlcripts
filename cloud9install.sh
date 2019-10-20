#!/bin/bash

clear

echo " "
echo "*****************************************************"
echo "WELCOME TO THE AUTOMATED INSTALLATION SCRIPT"
echo "-----------------------------------------------------"
echo " "
echo " This script will set up a cloud9 IDE  on your target server"
echo " "
echo "*****************************************************"

echo " "
echo "****************************************************************"
echo "Please enter the data path you would like to use to access Cloud9"
echo "****************************************************************"
read d

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

cat <<EOF >> /etc/init.d/cloud9-daemon
#!/bin/bash

### BEGIN INIT INFO
# Provides:          cloud9
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Simple script to start cloud9 at boot
# Description:       A simple script which will start / stop cloud9 at boot / shutdown.
### END INIT INFO

# If you want a command to always run, put it here

# Carry out specific functions when asked to by the system
case "$1" in
  start)
    # echo "Starting noip"
    # run application you want to start
    cd /root/c9sdk
    sudo nodejs /root/c9sdk/server.js -p 8181 -l 0.0.0.0 -a : -w /media/NASDRIVE/workspace &
    #echo "Launching cloud9 with workspace root set to /media/NASDRIVE/workspace"
    ;;
  stop)
    echo "Stopping cloud9"
    # kill application you want to stop
    pkill -f "node ./server.js"
    ;;
  *)
    echo "Usage: /etc/init.d/cloud9 {start|stop}"
    exit 1
    ;;
esac

exit 0
EOF

sudo chmod 755 /etc/init.d/cloud9-daemon

sudo update-rc.d cloud9-daemon defaults

sudo mkdir -p $d/workspace

clear

echo " "
echo "*****************************************************"
echo "THE INSTALLATION HAS FINSIHED"
echo "-----------------------------------------------------"
echo " "
echo " Please browse to your IP:8181 in your browser to access cloud9"
echo " "
echo "**************************************************************************************************************"
