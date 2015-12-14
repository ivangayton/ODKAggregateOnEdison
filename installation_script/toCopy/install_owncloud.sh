#!/bin/bash
cd tmp

wget -nv https://download.owncloud.org/download/repositories/stable/Debian_7.0/Release.key -O Release.key

apt-key add - < Release.key

sh -c "echo 'deb http://download.owncloud.org/download/repositories/stable/Debian_7.0/ /' >> /etc/apt/sources.list.d/owncloud.list"

apt-get update

apt-get install -y owncloud

