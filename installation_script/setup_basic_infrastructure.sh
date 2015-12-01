#!/bin/bash

apt-get update
apt-get upgrade
mv /var /home/edison/
ln -s /home/edison/var/ /var
apt-get install -y openjdk-7-jdk
apt-get install -y tomcat6 tomcat6-admin

# Assuming there is a copy of tomcat-users.xml in the
# same folder as this script, overwrite the stock
# tomcat-users.xml file with it.
mv tomcat-users.xml /etc/tomcat6/tomcat-users.xml

echo deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main >> /etc/apt/sources.list.d/pgdg.list
apt-get install wget ca-certificates
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt-get update
apt-get install postgresql-9.4 postgresql-client

# now run a script within postgresql as user postgres
# don't know how to do that yet

