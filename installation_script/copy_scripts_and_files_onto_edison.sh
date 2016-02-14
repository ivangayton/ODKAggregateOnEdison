#!/bin/bash

set -e
source remote-execution.sh

do_on_edison <<< "
if [ ! -d /home/edison/scripts ]; then
  echo creating a folder in /home/edison for scripts
  mkdir /home/edison/scripts
fi

if [ ! -d /home/edison/scripts/files ]; then
  echo creating a folder in /home/edison for files
  mkdir /home/edison/scripts/files
fi
"

echo Copying a bunch of scripts onto the Edison to set up the server
copy_to_edison toCopy/setup_basic_infrastructure.sh /home/edison/scripts/
copy_to_edison toCopy/install_ODK_Aggregate.sh /home/edison/scripts/
copy_to_edison toCopy/setup_edison_as_ap.sh /home/edison/scripts
copy_to_edison toCopy/expect_script_for_hostapd_install.exp /home/edison/scripts/
copy_to_edison toCopy/be_ap.sh /home/edison/scripts/
copy_to_edison toCopy/be_client.sh /home/edison/scripts

echo Setting all of those scripts to be executable
do_on_edison <<<"
chmod +x /home/edison/scripts/setup_basic_infrastructure.sh
chmod +x /home/edison/scripts/install_ODK_Aggregate.sh
chmod +x /home/edison/scripts/setup_edison_as_ap.sh
chmod +x /home/edison/scripts/expect_script_for_hostapd_install.exp
chmod +x /home/edison/scripts/be_client.sh
chmod +x /home/edison/scripts/be_ap.sh
"

echo Copying a bunch of assorted files onto the Edison
copy_to_edison toCopy/ODKAggregate.war /home/edison/scripts/files/
copy_to_edison toCopy/create_db_and_user.sql /home/edison/scripts/files/
copy_to_edison toCopy/index.html /home/edison/scripts/files/

