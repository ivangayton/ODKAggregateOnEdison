#!/bin/bash

apt-get update
apt-get -y upgrade

# relocate /var for partition space reasons
mv /var /home/edison/
ln -s /home/edison/var/ /var

# java 7
apt-get -y install openjdk-7-jdk

# tomcat 7
apt-get -y install tomcat7 tomcat7-admin

# Add tomcat users with permissions so that ODK Aggregate can use Tomcat
cp /etc/tomcat7/tomcat-users.xml /etc/tomcat7/tomcat-users.xml.bak
perl -0777 -i -pe 's/<\/tomcat-users>/<role rolename="manager-gui"\/>\n<role rolename="admin"\/>\n<user username="admin" password="admin" roles="admin,manager-gui"\/>\n<\/tomcat-users>/igm' /etc/tomcat7/tomcat-users.xml

# Edit the tomcat context (needed for ODK Aggregate to function on Tomcat7
cp /etc/tomcat7/context.xml /etc/tomcat7/context.xml.bak
perl -0777 -i -pe 's/<Context>/<Context useHttpOnly="false">/igm' /etc/tomcat7/context.xml

# Install PostgreSQL
echo 'deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main' >> /etc/apt/sources.list.d/pgdg.list

apt-get -y install wget ca-certificates
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt-get update
apt-get -y install postgresql
apt-get -y install postgresql-client

# Change Postgres password

su - postgres -c "psql -U postgres -d postgres -c \"alter user postgres with password 'all4one';\""

apt-get -y install nginx
service nginx start

# Move nginx html file folder to /home/ for partition space reasons 
mv /usr/share/nginx/www /home/edison/
ln -s /home/edison/www/ /usr/share/nginx/www

# Create a quickie welcome page for the Nginx server
mv files/index.html /usr/share/nginx/www/

