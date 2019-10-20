#!/bin/bash

clear

echo " "
echo "*****************************************************"
echo "WELCOME TO THE AUTOMATED INSTALLATION SCRIPT"
echo "-----------------------------------------------------"
echo " "
echo " This script will set up a qbittorrent-nox, samba"
echo " "
echo "*****************************************************"

sudo apt install ntfs-3g
sudo mkdir /media/NASDRIVE
sudo chmod 770 /media/NASDRIVE

echo " "
echo "****************************************************************"
echo "Please enter the data path you would like to use to access nextCloud"
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

echo " "
echo "***************************************************************"
echo "INSTALLING QBITTORRENT-DAEMON"
echo "---------------------------------------------------------------"

cat <<EOF >> /etc/init.d/qbittorrent-nox-daemon
#! /bin/sh
### BEGIN INIT INFO
# Provides:          qbittorrent-nox
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Starts QBittorrent
# Description:       Start qbittorrent-nox on start. Change USER= before running
### END INIT INFO
 
# Author: Jesper Smith
#
 
# Do NOT "set -e"
 
# PATH should only include /usr/* if it runs after the mountnfs.sh script
PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="QBittorrent"
NAME=qbittorrent-nox
DAEMON=/usr/bin/$NAME
DAEMON_ARGS=""
PIDFILE=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/qbittorrent
USER=root
 
# Exit if the package is not installed
[ -x "$DAEMON" ] || exit 0
 
# Read configuration variable file if it is present
[ -r /etc/default/$NAME ] && . /etc/default/$NAME
 
# Load the VERBOSE setting and other rcS variables
. /lib/init/vars.sh
 
# Define LSB log_* functions.
# Depend on lsb-base (>= 3.0-6) to ensure that this file is present.
. /lib/lsb/init-functions
 
#
# Function that starts the daemon/service
#
do_start()
{
        # Return
        #   0 if daemon has been started
        #   1 if daemon was already running
        #   2 if daemon could not be started
        start-stop-daemon -c $USER -b -t --start --quiet  --exec $DAEMON  \
                || return 1
 
        start-stop-daemon -c $USER -b --start --quiet --exec $DAEMON -- \
               $DAEMON_ARGS \
               || return 2
        sleep 1
}
 
#
# Function that stops the daemon/service
#
do_stop()
{
        start-stop-daemon -c $USER --quiet  --stop --exec $DAEMON
        sleep 2
        return "$?"
}
 
 
case "$1" in
  start)
        [ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC" "$NAME"
        do_start
        case "$?" in
               0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
               2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
        esac
        ;;
  stop)
        [ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
        do_stop
        case "$?" in
               0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
               2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
        esac
        ;;
  status)
       status_of_proc "$DAEMON" "$NAME" && exit 0 || exit $?
       ;;
  restart|force-reload)
        log_daemon_msg "Restarting $DESC" "$NAME"
        do_stop
        case "$?" in
          0|1)
               do_start
               case "$?" in
                       0) log_end_msg 0 ;;
                       1) log_end_msg 1 ;; # Old process is still running
                       *) log_end_msg 1 ;; # Failed to start
               esac
               ;;
          *)
                # Failed to stop
               log_end_msg 1
               ;;
        esac
        ;;
  *)
        #echo "Usage: $SCRIPTNAME {start|stop|restart|reload|force-reload}" >&2
        echo "Usage: $SCRIPTNAME {start|stop|status|restart|force-reload}" >&2
        exit 3
        ;;
esac
EOF

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