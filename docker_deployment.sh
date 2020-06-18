#!/bin/bash
# --------------------------------------------------
# Can be run against Debian 9, 10, Ubuntu 18.04+
# --------------------------------------------------

#---------------------------------------------------
# This script install the docker containers for mediabase
# NAS along with portainer service. The docker location
# will be moved to the SSD base so that it doesn't block
# mico-sd storage
# USAGE:
#       $# chmod +x docker_deployment.sh
#       $#  ./docker_deployment.sh
#--------------------------------------------------- 
echo '==>Initial Setup...'
#sudo apt update
#sudo apt install curl git -y

#echo '==>Installing Docker Service...'
#sudo curl -sSL get.docker.com | sh

#echo '==>Updating Docker location...'
#sed -i 's|/usr/bin/dockerd -H fd|/usr/bin/dockerd -g /media/NASDRIVE/docker -H fd|g' /lib/systemd/system/docker.service

#echo '==>Reload Docker daemon...'
#sudo systemctl daemon-reload
#echo '==>Restart Docker..'
#sudo systemctl restart docker


#Installing Portainer
echo '==>Creating Portainer Volume...'
sudo docker volume create portainer_data

echo '==>Installing Portainer...'

docker run -d \
 -p 9000:9000 \
 --name portainer \
 --restart always \
 -v /var/run/docker.sock:/var/run/docker.sock \
 -v portainer_data:/data \
 portainer/portainer

#Installing Qbittorrent
echo '==>Installing qBittorrent docker...'
  docker run -d \
  --name=qbittorrent-nox \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Kolkata \
  -e WEBUI_PORT=8112 \
  -p 6881:6881 \
  -p 6881:6881/udp \
  -p 8112:8112 \
  -v /root/.config/qbittorrent:/config \
  -v /media/NASDRIVE/Completed:/downloads \
  --restart unless-stopped \
  linuxserver/qbittorrent

#Installing Jackett
echo '==>Installing Jackett docker...'
docker run -d \
  --name=jackett \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Kolkata \
  -p 9117:9117 \
  -v /root/.config/jackett:/config \
  --restart always \
  linuxserver/jackett

#Installing Sonarr
echo '==>Installing Sonarr...'
docker run -d\
  --name=sonarr \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Kolkata \
  -p 8989:8989 \
  -v /home/arijit/.config/sonarr:/config \
  -v /mnt/MEDIADRIVE/Media/TVShows:/tv \
  -v /mnt/DATADRIVE/Completed:/downloads \
  --restart always \
  linuxserver/sonarr
  
  #Installing Radarr
  docker run -d \
  --name=radarr \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Kolkata \
  -p 7878:7878 \
  -v /home/arijit/.config/radarr:/config \
  -v /mnt/MEDIADRIVE/Media/Movies:/movies \
  -v /mnt/DATADRIVE/Completed:/downloads \
  --restart always \
  linuxserver/radarr

#Installing JellyFin
echo '==>Installing Jellyfin docker...'
docker run -d \
  --name=jellyfin \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Kolkata \
  -p 8096:8096 \
  -v /root/.config/jellyfin:/config \
  -v /media/NASDRIVE/Media/TVshows:/data/tvshows \
  -v /media/NASDRIVE/Media/Movies:/data/movies \
  --restart always \
  linuxserver/jellyfin

#Installing Cloud9
echo '==>Installing Cloud9 service...'
docker run -d \
  --name=cloud9 \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Kolkata \
  -p 8000:8000 \
  --restart always \
  linuxserver/cloud9

#Installing Nextcloud
echo '==>Installing NextCloud service...'
docker run -d \
  --name=nextcloud \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Kolkata \
  -p 443:443 \
  -v /root/.config/nextcloud:/config \
  -v /media/NASDRIVE/nextcloud/data:/data \
  --restart always \
  linuxserver/nextcloud

echo '==>Installing Remmina service...'
docker run -d\
  --name=remmina \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Kolkata \
  -p 3999:3000 \
  -v /root/.config/remmina:/config \
  --restart always \
  linuxserver/remmina

echo '==>Installing Double Commander service...'
docker run -d \
  --name=doublecommander \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asis/Kolkata \
  -p 3000:3000 \
  -v /home/arijit/.config/doublecommander:/config \
  -v /mnt:/data \
  --restart always \
  linuxserver/doublecommander

echo '#######################################'
echo 'All docker services have been deployed successfully'
echo '  '
echo '  Access Portainer via http://my-ip:9000'
echo '  Access the docker containers via "http://my-ip:port"'
echo '  a)qBittorrent via http://my-ip:8112'
echo '  b)Jackett via http://my-ip:9117'
echo '  c)Sonarr via http://my-ip:8989'
echo '  d)Jellyfin via http://my-ip:8096'
echo '  e)NextCloud via https://my-ip/nextcloud'
echo '  f)Remmina via http://my-ip:3999'
echo '  g)Double Commander via http://my-ip:3000'
echo '  h)Radarr via http://my-ip:7878'
echo '#######################################'
