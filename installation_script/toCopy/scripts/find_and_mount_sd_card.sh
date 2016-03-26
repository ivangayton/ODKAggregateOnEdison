#!/bin/bash

# if ls /dev/mmcblk1p1 returns something:

mkdir /media/sd1

echo '/dev/mmcblk1p1 /media/sd1 auto defaults 1 1' >> /etc/fstab

