#!/bin/bash

set -e

echo moving /usr/share to /home partition for space reasons
mv share/ /home/edison/share
ln -s /home/edison/share/ /usr/share

echo installing Apache web server
apt-get install -y apache2
apt-get install libapache2-mod-php5

echo installing MariaDB MySQL server
apt-get install -y python-software-properties
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
add-apt-repository 'deb [arch=amd64,i386] http://mariadb.mirror.iweb.com/repo/10.1/debian wheezy main'
apt-get update

# Installer needs a user interaction for a root password for the db installation
echo please install a database using the command 
echo apt-get install -y mariadb-server
echo and give it a password (and do remember that password)

apt-get install -y php5-gd php5-json php5-mysql php5-curl

apt-get install -y php5-intl php5-mcrypt php5-imagick

echo downloading and unzipping owncloud
apt-get install -y unzip
wget -O /var/www/owncloud-9.0.0.zip https://download.owncloud.org/community/owncloud-9.0.0.zip
unzip /var/www/owncloud-9.0.0.zip
rm owncloud-9.0.0.zip

echo 'Alias /owncloud "/var/www/owncloud/"

<Directory /var/www/owncloud/>
  Options +FollowSymlinks
  AllowOverride All

 <IfModule mod_dav.c>
  Dav off
 </IfModule>

 SetEnv HOME /var/www/owncloud
 SetEnv HTTP_HOME /var/www/owncloud

</Directory>' > /etc/apache2/sites-available/owncloud.conf

ln -s /etc/apache2/sites-available/owncloud.conf /etc/apache2/sites-enabled/owncloud.conf

a2enmod rewrite
a2enmod headers

service apache2 restart

# a2enmod ssl
# a2ensite default-ssl
# service apache2 reload

./set_permissions_for_owncloud.sh

# su as www-data, run the crazy install program occ with various settings, watch it crash, figure out how to disable binary logging in the database (comment out a line in /etc/mysql/my.conf)...

php occ maintenance:install --database "mysql" --database-name "owncloud"  --database-user "root" --database-pass "plumpynut" --admin-user "admin" --admin-pass "plumpynut"
