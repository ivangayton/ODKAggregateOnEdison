#!/bin/bash

# Installs ODK Aggregate on the Edison. Presumes all the other infrastructure
# is in place, and the appropriate WAR file and sql script have been copied 
# into /home/edison/scripts/files

echo Running the SQL script that creates the user and database for Aggregate
su - postgres -c "
psql -U postgres -f /home/edison/files/create_db_and_user.sql
"

echo Copying the ODKAggregate.war file into the Tomcat webapps directory
cp /home/edison/scripts/files/ODKAggregate.war /var/lib/tomcat7/webapps/
