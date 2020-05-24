#!/bin/bash
# --------------------------------------------------
# Can be run against Debian 9, 10, Ubuntu 18.04+
# --------------------------------------------------

#---------------------------------------------------
# This script install the deluge torrent as well the
# Deluge Web UI.
# Note: The service will be running as root all time.
# USAGE:
#       $# sudo chmod +x deluge_install.sh
#       $# sudo ./delueg_install.sh
#--------------------------------------------------- 

sudo apt update && sudo apt upgrade -y

echo 'installing Deluge..'
sudo apt install deluged deluge-web -y

echo ' setting deluge to run as a service..'
cat <<EOF >> /etc/systemd/system/deluged.service
[Unit]
Description=Deluge Daemon
After=network-online.target

[Service]
Type=simple
User=root
Group=root
UMask=002
ExecStart=/usr/bin/deluged -d
Restart=on-failure
TimeoutStopSec=300

[Install]
WantedBy=multi-user.target
EOF

echo 'Setting permission..'
sudo systemctl enable deluged.service

echo 'Setting  Deluge Web interface as a service..'
cat <<EOF >> /etc/systemd/system/deluged-web.service
[Unit]
Description=Deluge Web Interface
After=network-online.target deluged.service
Wants=deluged.service

[Service]
Type=simple
User=root
Group=root
UMask=002
ExecStart=/usr/bin/deluge-web
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo 'Setting permissions..'
sudo systemctl enable deluge-web.service

echo 'Setting configurations..'
sudo systemctl start deluged
sudo systemctl start deluge-web

echo 'Deluge configuration completed'
echo 'Please access deluge at http://my-ip:8112'

