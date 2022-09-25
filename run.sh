#!/bin/bash

# or in fstab:
# .host:/baidupan    /home/ubuntu/apps-docker/baidunetdisk-docker/download    fuse.vmhgfs-fuse    defaults,nobootwait,allow_other    0    0
sudo docker-compose down -v
mv download download.old
mkdir download
sudo /usr/bin/vmhgfs-fuse .host:/baidupan /home/ubuntu/apps-docker/baidunetdisk-docker/download -o subtype=vmhgfs-fuse,allow_other
sudo docker-compose up -d
