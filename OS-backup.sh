#!/bin/bash
echo "Backup from ROOTFS to zip File. In progress.."
bckdir="/media/DataDrive/backup"

# Create working directory
if [ ! -d ${bckdir} ]; then
  mkdir ${bckdir}
fi

#Start rsync
rsync -aAX --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"} / /${bckdir}
echo "RSYNC done.gzipping directory..."
cd /media/DataDrive && tar czf backup.$(date +%d%h%Y.%H%M%P).tar.gz ${bckdir}
rm -rf ${bckdir}
echo "Backup process completed"



