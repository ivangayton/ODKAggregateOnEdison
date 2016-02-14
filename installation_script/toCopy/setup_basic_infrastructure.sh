#!/bin/bash

set -e

apt-get update
apt-get -y upgrade

echo moving the /var/ folder to /home/edison for partition space reasons
mv /var /home/edison/
ln -s /home/edison/var/ /var

echo installing java 7
apt-get -y install openjdk-7-jdk

echo installing tomcat 7
apt-get -y install tomcat7 tomcat7-admin

echo Adding tomcat users with permissions so that we can set up services
cp /etc/tomcat7/tomcat-users.xml /etc/tomcat7/tomcat-users.xml.bak
sed -i '/<\/tomcat-users>/c\<role rolename="manager-gui"\/>\n<role rolename="admin"\/>\n<user username="admin" password="admin" roles="admin,manager-gui\/">\n<\/tomcat-users>' /etc/tomcat7/tomcat-users.xml

echo Editing the tomcat context, needed for ODK Aggregate to work on Tomcat7
cp /etc/tomcat7/context.xml /etc/tomcat7/context.xml.bak
sed -i '/<Context>/c\<Context useHttpOnly="false">' /etc/tomcat7/context.xml

echo Installing PostgreSQL
echo 'deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main' >> /etc/apt/sources.list.d/pgdg.list

apt-get -y install wget ca-certificates
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt-get update
apt-get -y --force-yes install postgresql postgresql-client

echo Changing Postgres root password to secure the installation

su - postgres -c "psql -U postgres -d postgres -c \"alter user postgres with password 'all4one';\""

apt-get -y install nginx
service nginx start

echo Moving nginx html file folder to /home/edison for partition space reasons 
if [ ! -d /home/edison/www ]; then
  mv /usr/share/nginx/www /home/edison/
  ln -s /home/edison/www/ /usr/share/nginx/www
fi

cp Copying a quickie welcome page for the Nginx server into its home folder
mv files/index.html /usr/share/nginx/www/
