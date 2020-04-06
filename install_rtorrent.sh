#!/bin/bash
VERSION="1.1" 

# INTRODUCTION
    # This script installs and configures rTorrent on a Raspberry Pi.
    # Included: ruTorrent, nginx, php-fpm

# HOW TO USE THIS SCRIPT
    # Log in to the RPi.
    # Open a terminal if you are in GUI mode.
    # Download this script:
        # wget -O rtorrent_pi.sh http://iqes.pl/upload/rtorrent_pi.sh
    # Edit any SETTINGS
        # nano rtorrent_pi.sh (Ctrl-o to save and Ctrl-x to exit).
    # Set execute permssions so the script can run:
        # chmod u+x rtorrent_pi.sh
    # Run this script:
        # ./rtorrent_pi.sh


# PREREQUISITES
    # Rasberry Pi 
    # root distribution installed (This script may work on other Debian based distibutions an on other devices).
    # The user who runs this script must have sudo rights. A password is required.
    # The user who runs this script must have write access to the current directory.
    # The RPi must be connected to the internet using the ethernet connection.
#while :
#do     

# GLOBAL
SCRIPT_NAME='rtorrent_pi.sh'
AUTHOR='gurukool'
LOGFILE="/tmp/rtorrent_install.log"    
USER='root'

# WWW SETTINGS
WWW_DIRECTORY='/var/www'         # Do not include a slash at the end of the path

# RTORRENT SETTINGS
RTORRENT_USER='root'            # Permissions
RTORRENT_GROUP='root'           # Permissions
MAX_PEERS_SEED='50'
MIN_PEERS_SEED='2'
MAX_PEERS='50'
MIN_PEERS='2'
PORT_RANGE='61040-61050'
MAX_UPLOADS='30'
DOWNLOAD_RATE='0'
UPLOAD_RATE='0'
MAX_DOWNLOADS_DIV='0'
MAX_UPLOADS_GLOBAL='70'
MAX_DOWNLOADS_GLOBAL='50'
DHT='disable'
DHT_PORT='6881'
PEER_EXCHANGE='no'
SESSION_DIRECTORY='/media/NASDRIVE/rtorrent/session'
WATCH_DIRECTORY='/media/NASDRIVE/Incomplete'
DOWNLOAD_DIRECTORY='/media/NASDRIVE/Completed'
RTORRENT_CONFIG='/media/NASDRIVE'
RTORRENT_SOCKET='/tmp/rtorrent.sock'
NICE='7'                        #Nicelevel of rtorrent

# RUTORRENT SETTINGS
PORT='9096'                     #port for rutorrent website http://localhost:PORT
PLUGINS='y'                     #install plugin pack with f.e. unpack (unrar)
PLUGINS_URL='http://dl.bintray.com/novik65/generic/plugins-3.6.tar.gz'
RUTORRENT_URL='http://dl.bintray.com/novik65/generic/rutorrent-3.6.tar.gz'


# START OF SCRIPT
clear
echo '-----------------------------------------------------------'
echo "$SCRIPT_NAME"
echo 'Install and configure rtorrent on a root...'
echo -e "Version: $VERSION\nCreated by: $AUTHOR"
echo '-----------------------------------------------------------'

# Prompt for the sudo password if required
sudo echo ''

echo 'Updating package lists...'
sudo apt-get update >>"$LOGFILE" 2>&1

echo 'Installing rtorrent...'
sudo apt-get -yqq install rtorrent >>"$LOGFILE" 2>&1

echo 'Installing dtach...'
sudo apt-get -yqq install dtach >>"$LOGFILE" 2>&1

echo 'Installing php-fpm, and other dependancies...'
sudo apt-get -yqq install php-fpm libgd2-xpm-dev libpcrecpp0 libxpm4 >>"$LOGFILE" 2>&1

echo 'Installing nginx...'
sudo apt-get -yqq install nginx >>"$LOGFILE" 2>&1

echo 'Creating WWW directory...'
sudo mkdir -p "$WWW_DIRECTORY" >>"$LOGFILE" 2>&1
sudo chown www-data:www-data "$WWW_DIRECTORY" >>"$LOGFILE" 2>&1

echo 'Creating rTorrent watch directory...'
sudo mkdir -p "$WATCH_DIRECTORY" >>"$LOGFILE" 2>&1
sudo chown $RTORRENT_USER:$RTORRENT_GROUP "$WATCH_DIRECTORY" >>"$LOGFILE" 2>&1
#sudo chmod 777 "$SESSION_DIRECTORY" >>"$LOGFILE" 2>&1

echo 'Creating rTorrent session directory...'
sudo mkdir -p "$SESSION_DIRECTORY" >>"$LOGFILE" 2>&1
sudo chown $RTORRENT_USER:$RTORRENT_GROUP "$SESSION_DIRECTORY" >>"$LOGFILE" 2>&1
#sudo chmod 777 "$SESSION_DIRECTORY" >>"$LOGFILE" 2>&1

echo 'Creating rTorrent download directory...'
sudo mkdir -p "$DOWNLOAD_DIRECTORY" >>"$LOGFILE" 2>&1
sudo chown $RTORRENT_USER:$RTORRENT_GROUP "$DOWNLOAD_DIRECTORY" >>"$LOGFILE" 2>&1
#sudo chmod 777 "$DOWNLOAD_DIRECTORY" >>"$LOGFILE" 2>&1

echo 'Installing rutorrent...'
cd $WWW_DIRECTORY
sudo wget -O rutorrent.tar.gz $RUTORRENT_URL >>"$LOGFILE" 2>&1
sudo tar xvfx rutorrent.tar.gz >>"$LOGFILE" 2>&1
sudo rm rutorrent.tar.gz >>"$LOGFILE" 2>&1

if [[ $PLUGINS == 'y' ]]; then
    echo 'Installing rutorrent plugins...'
    cd $WWW_DIRECTORY/rutorrent
    sudo wget -O plugins.tar.gz $PLUGINS_URL >>"$LOGFILE" 2>&1
    sudo tar xvfx plugins.tar.gz >>"$LOGFILE" 2>&1
    sudo rm plugins.tar.gz >>"$LOGFILE" 2>&1
    echo 'Installing rutorrent plugins dependancies...'
    sudo apt-get -yqq install php-cli unrar curl >>"$LOGFILE" 2>&1
fi

echo 'Setting rtorrent...'
sudo rm $RTORRENT_CONFIG/.rtorrent.rc >>"$LOGFILE" 2>&1
echo '# ~/.rtorrent.rc and Remember to enable/modify the options as needed.' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# uncomment the options you wish to enable.' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Based on original .rtorrent.rc file from The libTorrent and rTorrent Project' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Modified by Lemonberry for rtGui rtgui - Web based front-end for "rTorrent" - the Linux command line BitTorrent client - Google Project Hosting' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '#' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# This assumes the following directory structure:' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '#' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# /Torrents/Downloading - temporaray location for torrents while downloading  see "directory" ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# /Torrents/Complete - Torrents are moved here when complete  see "on_finished" ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# /Torrents/TorrentFiles/Auto - The autoload directory for rtorrent to use. Place a file' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# in here, and rtorrent loads it #automatically.  see "schedule = watch_directory" ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# /Torrents/Downloading/rtorrent/session - for storing rtorrent session information' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '#' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Maximum and minimum number of peers to connect to per torrent.' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo "min_peers = $MIN_PEERS" | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo "max_peers = $MAX_PEERS" | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Same as above but for seeding completed torrents  -1 = same as downloading ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo "min_peers_seed = $MIN_PEERS_SEED" | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo "max_peers_seed = $MAX_PEERS_SEED" | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Maximum number of simultanious uploads per torrent.' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo "max_uploads = $MAX_UPLOADS" | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Global upload and download rate in KiB. "0" for unlimited.' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo "download_rate = $DOWNLOAD_RATE" | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo "upload_rate = $UPLOAD_RATE" | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Change the divider used to calculate the max upload and download slots to use when the throttle is changed. Disable by setting 0.' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo "max_downloads_div = $MAX_DOWNLOADS_DIV" | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Max upload and download slots allowed. Disable by setiing 0.' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo "max_uploads_global = $MAX_UPLOADS_GLOBAL" | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo "max_downloads_global = $MAX_DOWNLOADS_GLOBAL" | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Default directory to save the downloaded torrents.' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo "directory = $DOWNLOAD_DIRECTORY" | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Default session directory. Make sure you dont run multiple instance' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# of seeder1rent using the same session directory. Perhaps using a' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# relative path?' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo "session = $SESSION_DIRECTORY" | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Watch a directory for new torrents, and stop those that have been' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# deleted.' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo 'schedule = untied_directory,5,5,stop_untied=' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo "schedule = watch_directory,5,5,load_start=$WATCH_DIRECTORY/*.torrent" | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Close torrents when diskspace is low. */' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo 'schedule = low_diskspace,5,60,close_low_diskspace=100M' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Stop torrents when reaching upload ratio in percent,' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# when also reaching total upload in bytes, or when' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# reaching final upload ratio in percent.' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# example: stop at ratio 2.0 with at least 200 MB uploaded, or else ratio 20.0' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# schedule = ratio,60,60,stop_on_ratio=200,200M,2000' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# When the torrent finishes, it executes mv -n <base_path> ~/Download/' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# and then sets the destination directory to "~/Download/". 0.7.7+' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# on_finished = move_complete,"execute=mv,-u,$d.get_base_path=,/media/DataDrive/Completed ;d.set_directory=/media/DataDrive/Completed/"' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# The ip address reported to the tracker.' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# ip = 127.0.0.1' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# ip = rakshasa.no' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# The ip address the listening socket and outgoing connections is' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# bound to.' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# bind = 127.0.0.1' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# bind = rakshasa.no' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Port range to use for listening.' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo "port_range = $PORT_RANGE" | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Start opening ports at a random position within the port range.' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# port_random = yes' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo "scgi_local = $RTORRENT_SOCKET" | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo "execute = {sh,-c,/bin/chgrp www-data $RTORRENT_SOCKET}" | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo "execute = {sh,-c,/bin/chmod g=rwx $RTORRENT_SOCKET}" | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Check hash for finished torrents. Might be usefull until the bug is' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# fixed that causes lack of diskspace not to be properly reported.' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo 'check_hash = no' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Set whetever the client should try to connect to UDP trackers.' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# use_udp_trackers = no' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Alternative calls to bind and ip that should handle dynamic ips.' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# schedule = ip_tick,0,1800,ip=rakshasa' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# schedule = bind_tick,0,1800,bind=rakshasa' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Encryption options, set to none default or any combination of the following:' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# allow_incoming, try_outgoing, require, require_RC4, enable_retry, prefer_plaintext' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '#' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# The example value allows incoming encrypted connections, starts unencrypted' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# outgoing connections but retries with encryption if they fail, preferring' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# plaintext to RC4 encryption after the encrypted handshake' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '#' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo 'encryption = allow_incoming,enable_retry,prefer_plaintext' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Enable DHT support for trackerless torrents or when all trackers are down.' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# May be set to "disable"  completely disable DHT , "off"  do not start DHT ,' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# "auto"  start and stop DHT as needed , or "on"  start DHT immediately .' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# The default is "off". For DHT to work, a session directory must be defined.' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo "dht = $DHT" | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# UDP port to use for DHT.' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '#' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
if [[ $DHT == 'disable' ]]; then
    echo "# dht_port = $DHT_PORT" | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
else
    echo "dht_port = $DHT_PORT" | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
fi
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Enable peer exchange  for torrents not marked private ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '#' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo "peer_exchange = $PEER_EXCHANGE" | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '#' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Do not modify the following parameters unless you know what youre doing.' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '#' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Hash read-ahead controls how many MB to request the kernel to read' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# ahead. If the value is too low the disk may not be fully utilized,' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# while if too high the kernel might not be able to keep the read' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# pages in memory thus end up trashing.' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# hash_read_ahead = 8' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Interval between attempts to check the hash, in milliseconds.' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# hash_interval = 10' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Number of attempts to check the hash while using the mincore status,' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# before forcing. Overworked systems might need lower values to get a' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# decent hash checking rate.' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# hash_max_tries = 5' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Max number of files to keep open simultaniously.' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# max_open_files = 128' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Number of sockets to simultaneously keep open.' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# max_open_sockets = 728' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Example of scheduling commands: Switch between two ips every 5' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# seconds.' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# schedule = "ip_tick1,5,10,ip=torretta"' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# schedule = "ip_tick2,10,10,ip=lampedusa"' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# Remove a scheduled event.' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '# schedule_remove = "ip_tick1"' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo ' ' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo '#Teste' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null
echo 'encoding_list = UTF-8' | sudo tee -a $RTORRENT_CONFIG/.rtorrent.rc > /dev/null

echo 'Setting permissions for rtorrent setting file...'
sudo chmod u+x $RTORRENT_CONFIG/.rtorrent.rc >>"$LOGFILE" 2>&1
sudo chown $RTORRENT_USER:$RTORRENT_GROUP $RTORRENT_CONFIG/.rtorrent.rc >>"$LOGFILE" 2>&1

echo 'Setting rtorrent autostart...'
sudo rm /etc/default/rtorrent >>"$LOGFILE" 2>&1
echo 'ENABLED=1' | sudo tee -a /etc/default/rtorrent > /dev/null
echo '' | sudo tee -a /etc/default/rtorrent > /dev/null
echo "CONFIG_FILE=$RTORRENT_CONFIG/.rtorrent.rc" | sudo tee -a /etc/default/rtorrent > /dev/null
echo "NICE=$NICE" | sudo tee -a /etc/default/rtorrent > /dev/null

sudo rm /etc/init.d/rtorrent >>"$LOGFILE" 2>&1
echo '#!/bin/sh' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '### BEGIN INIT INFO' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '# Provides: rtorrent_autostart' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '# Required-Start: $local_fs $remote_fs $network $syslog $netdaemons' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '# Required-Stop: $local_fs $remote_fs' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '# Default-Start: 2 3 4 5' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '# Default-Stop: 0 1 6' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '# Short-Description: rtorrent script using screen(1)' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '# Description: rtorrent script using screen(1) to keep torrents working without the user logging in' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '### END INIT INFO' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '. /etc/default/rtorrent' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo 'NAME=rtorrent' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo 'SCRIPTNAME=/etc/init.d/rtorrent' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo 'PID_FILE=/tmp/rtorrent.pid' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo 'PID_PATH=$(dirname $PID_FILE)' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '# path du fichier temporaire' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo 'TMP=/tmp/rtorrent.dtach' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '# user qui lance le torrent' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo 'USER=root' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '# chemin vers fichier conf' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo 'start() {' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '        echo -n "Starting $NAME: "' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '    start-stop-daemon --start --nicelevel $NICE --background --pidfile $PID_FILE --exec /usr/bin/dtach --  -n $TMP rtorrent -n -o import=$CONFIG_FILE' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '    sleep 1' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '        chgrp www-data /tmp/rtorrent.sock' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '        chmod 0775 /tmp/rtorrent.sock' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '        chmod 666 /tmp/rtorrent.dtach' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '        echo "started" ' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '}' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo 'stop() {' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '        echo -n "Stopping $NAME: "' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '        killall -r "rtorrent"' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '        echo "stopped"' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '} ' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo 'restart() { ' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '                 stop' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '                sleep' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '        start' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '}' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo 'case $1 in' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '        start)' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '               start' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '        ;;' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '        stop)' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '                stop' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '        ;;' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '        restart)' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '                restart' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '        ;;' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '        *)' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '                echo "Usage:  {start|stop|restart}" >&2' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '                exit 2' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo '        ;;' | sudo tee -a /etc/init.d/rtorrent > /dev/null
echo 'esac' | sudo tee -a /etc/init.d/rtorrent > /dev/null

echo 'Setting rtorrent autostart permissions...'
sudo chmod 755 /etc/init.d/rtorrent >>"$LOGFILE" 2>&1

echo 'Setting rutorrent...'
sudo sed -i "s:$scgi_port = 5000;.*:$scgi_port = 0;:" $WWW_DIRECTORY/rutorrent/conf/config.php >>"$LOGFILE" 2>&1
sudo sed -i "s:$scgi_host = \"127\.0\.0\.1\";.*:$scgi_host = \"unix\://$RTORRENT_SOCKET\";:" $WWW_DIRECTORY/rutorrent/conf/config.php >>"$LOGFILE" 2>&1

echo 'Setting ruttorent website in nginx...'
sudo rm /etc/nginx/sites-available/rutorrent >>"$LOGFILE" 2>&1
echo 'server {' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo '' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo " listen $PORT;" | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo ' ' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo " root $WWW_DIRECTORY/rutorrent;" | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo '' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo ' index index.html;' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo '' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo ' server_name rutorrent;' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo '' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo ' error_log /var/log/nginx/rutorrent_error.log;' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo '' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo ' access_log /var/log/nginx/rutorrent_access.log;' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo '' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo 'location ~ .php$ {' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo '' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo ' include /etc/nginx/fastcgi_params;' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo '' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo ' try_files $uri =404;' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo '' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo ' fastcgi_index index.php;' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo '' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo ' fastcgi_split_path_info ^(.+.php)(/.+)$;' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo '' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo ' fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo '' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo ' fastcgi_pass unix:/var/run/php-fpm.sock;' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo '' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo ' }' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo '' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo 'location /RPC2 {' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo '' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo ' scgi_pass unix:/etc/nginx/sites-available/rutorrent.sock;' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo '' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo ' include scgi_params;' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo '' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo ' }' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo '' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null
echo '}' | sudo tee -a /etc/nginx/sites-available/rutorrent > /dev/null

sudo ln -s /etc/nginx/sites-available/rutorrent /etc/nginx/sites-enabled/rutorrent

sudo sed -i 's/;env\[PATH\]/env\[PATH\]/g' /etc/php/7.3/fpm/pool.d/www.conf

echo 'Restart of included packages...'
sudo service php7.3-fpm restart
sudo service nginx restart
sudo /etc/init.d/rtorrent stop
sudo /etc/init.d/rtorrent start
echo 'Services restarted'

if grep "dpkg" $LOGFILE; then
#     echo 'Run this script once more!'
#     sudo dpkg --configure -a 
#     sudo rm /tmp/rtorrent.sock
#     sudo rm $LOGFILE
# else
    break;
    mv $LOGFILE /root
fi
#done

sudo update-rc.d rtorrent defaults

echo 'Installation succeded'
# end of script
