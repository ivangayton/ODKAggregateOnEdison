#!/bin/bash

# Run a script that installs a bunch of basic stuff like Java, Tomcat, 
# PostgreSQL, and Nginx (with a little welcome page).
./setup_basic_infrastructure.sh

# ACCESS POINT

apt-get -y install dnsmasq

# Set up Ubilinux to update with the repository for the "testing" versions
echo deb http://ftp.us.debian.org/debian testing main contrib non-free >> /etc/apt/sources.list

# avoid updating everything with testing versions
echo 'Package: *
Pin: release a=testing
Pin-Priority: 900' >> /etc/apt/preferences

# update so that the testing repos will be included in those scanned by Ubilinux
apt-get update

# install testing hostapd - best done via ssh not screen
# as there's a setup menu that can crash screen

apt-get -t testing install hostapd
# QUESTIONs
# Y to continue install
# Y to upgrade glibc
# Y to interrupt services
# N to keep current version

apt-get -y install dnsutils

# Domain name
echo "192.168.0.1   data.msf" >> /etc/hosts

# IP addresses

# set up the range of IP addresses offered by the Edison (uncomment line)
cp /etc/dnsmasq.conf /etc/dnsmasq.conf.bak
perl -0777 -i -pe 's/^#dhcp-range=192.168.0.50,192.168.0.150,12h/dhcp-range=192.168.0.50,192.168.0.150,12h/igm' /etc/dnsmasq.conf

# setup wifi
echo 'ssid=MSF_Data1
wpa_passphrase=plumpynut' >> /etc/hostapd/hostapd.conf

# backup
cp /etc/default/hostapd /etc/default/hostapd.bak

# edit /etc/hostapd/udhcpd-for-hostapd.conf (comment line and add replacement above)
cp /etc/hostapd/udhcpd-for-hostapd.conf /etc/hostapd/udhcpd-for-hostapd.conf.bak
perl -0777 -i -pe 's/^interface/interface lo\n#interface/igm' /etc/hostapd/udhcpd-for-hostapd.conf

# switch network configuration to be server - like calling custom 'beserver' function
cp /etc/network/interfaces_server.bak /etc/network/interfaces;
perl -0777 -i -pe 's/^#DAEMON_CONF="[a-zA-Z\/\.]*"/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/igm' /etc/default/hostapd;

# When you reboot you will hopefully have a fully working server
reboot


## ODK Aggregate configuration:
# port 8080
# domain data.msf
# db port 5432
# 127.0.0.1
# db username odk_user
# db password all4one
# db name ODK-Edison
# username surveyor

# now copy files across - e.g.
# scp ODKAggregate.war 192.168.0.1:/home/edison
# scp create_db_and_user.sql 192.168.0.1:/home/edison

# import database settings to postgres
su - postgres
psql
\cd /home/edison
\i create_db_and_user.sql
\q
exit

# copy across ODKAggregate and activate
# e.g. 'scp ODKAggregate.war root@192.168.0.1:/home/edison/'
cp /home/edison/ODKAggregate.war /var/lib/tomcat6/webapps/
service tomcat6 restart

echo "ODK-Edison installation successful!!"


# SD CARD SETUP

# # Mount an SD card for backing up data
# mkdir /home/edison/sd

# # plug in SD card and check id:
# dmesg -T | grep mmc1

# # to mount e.g. for id 'mmcblk1':
# # mount -t ext4 /dev/mmcblk1p1 /home/edison/sd/

# # mount during boot up
# perl -0777 -i -pe 's/^exit 0/# mount SD card\nmount -t ext4 \/dev\/mmcblk1p1 \/home\/edison\/sd\/ &\n\nexit 0/igm' /etc/rc.local

