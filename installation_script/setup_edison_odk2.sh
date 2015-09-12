#!/bin/bash

apt-get update
apt-get -y upgrade
apt-get clean
apt-get autoclean
apt-get -y autoremove

# relocate /var for partition space reasons
mv /var /home/edison/
ln -s /home/edison/var/ /var

# java 7
apt-get -y install openjdk-7-jdk

apt-get clean
apt-get autoclean
apt-get -y autoremove

# tomcat 6
apt-get -y install tomcat6

# seems unnecessary
#reboot

apt-get -y install tomcat6-admin

# edit tomcat user permissions
cp /etc/tomcat6/tomcat-users.xml /etc/tomcat6/tomcat-users.xml.bak
perl -0777 -i -pe 's/<\/tomcat-users>/<role rolename="manager"\/>\n<role rolename="admin"\/>\n<user username="admin" password="admin" roles="admin,manager"\/>\n<\/tomcat-users>/igm' /etc/tomcat6/tomcat-users.xml

service tomcat6 restart

# edit
echo 'deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main' >> /etc/apt/sources.list.d/pgdg.list

apt-get -y install wget ca-certificates
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt-get update
apt-get -y upgrade
#apt-get install postgresql-9.4 postgresql-client
apt-get -y install postgresql
apt-get -y install postgresql-client


#----------------------------------------------------
## Postgres stuff currently needs to be done manually

su - postgres
psql

# password
\password postgres
all4one
all4one

\q
exit

#----------------------------------------------------

apt-get update
apt-get -y install nginx
service nginx start

# move 
mv /usr/share/nginx/www /home/edison/
ln -s /home/edison/www/ /usr/share/nginx/www

# edit
echo "<html>
<head>
<title>ODK Aggregate in your pocket courtesy of the MSF-Data</title>
</head>
<body bgcolor='white' text='black'>
<center><h1>Welcome to the MSF-Data Micro-server.</h1>
<p>You are not on the Internet. This page is hosted on a tiny server near you.</p>
<p> Here is the local <a href='http://data.msf:8080/ODKAggregate'>Aggregate server.</a> Connect to it to upload blank forms and download completed forms. Use the same URL to connnect your ODK Collect applications on your surveyor's phones to the server.</p>
<p>You should install ODKCollect on your phone. Get it <a href='/files/ODK Collect v1.4.6 rev 1051.apk' download>here</a>.</p>
<p>Here, for that matter, is a copy of <a href='/files/net.osmand.plus_212.apk' download>OSMAND</a> which should be very helpful for navigating.</p>
<p>And here is the OSMAND <a href='/files/South_Kivu.obf' download>map file for South Kivu</a>.</p>
<h2>Good luck, stay safe, and support free software and open data!</h2>
</center>
</body>
</html>" > /usr/share/nginx/www/index.html


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
# y to install
# Y to ..?
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



echo "ODK-Edison installation successful!!"

