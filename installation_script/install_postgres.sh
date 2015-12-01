#!/bin/bash

echo deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main >> /etc/apt/sources.list.d/pgdg.list
apt-get install wget ca-certificates
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt-get update
apt-get install postgresql-9.4 postgresql-client

# now run a script within postgresql as user postgres
# don't know how to do that yet

