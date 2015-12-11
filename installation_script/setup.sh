#!/bin/bash

set -e
source remote-execution.sh
echo Please enter the local wifi network name:
read wifi_ssid
echo Please enter the local wifi password:
read  wifi_password
echo Please tell me what hostname you would like to give your server:
read new_hostname 

echo "I'm afraid you're going to have to give me root access if you want me to flash the Edison. You may be asked to enter your sudo password at some point during this installation"

sudo -p 'Password for user %u: ' echo $start

# We need Expect to be installed on the host machine to interact with 
# some of the installation scripts (and maybe to respond to the password
# challenge from the newly flashed Edison (password "edison") to install
# the ssh keys needed to get root access later.  Check if Expect is 
# already installed, and if not install it.
if ! type "expect" > /dev/null; then
  sudo apt-get install expect
fi

# Check if there's already a key in the file $HOME/.ssh/edison on the host
# If not, create it (below we'll place the key on the Edison as well so
# that we can copy stuff over to it with scp.
if [ ! -f $key_file ]; then
    ssh-keygen -t dsa -f $key_file -P ''
fi
pubkey=$(cat $key_file.pub)

# Add ssh key pair so that we can do other stuff on the Edison as root
# without constantly needing the user to respond to password challenges
do_on_edison <<< "
mkdir -p .ssh
echo '$pubkey' >> .ssh/authorized_keys &&
    echo 'Added ssh access to $target successfully.'
"

# Configure the Edison to get on the internet using the local wifi
do_on_edison <<< "
if [ ! -f /etc/network/interfaces.bak ]; then
  cp /etc/network/interfaces /etc/network/interfaces.bak
fi

sed -i '0,/\#auto wlan0/s/\#auto wlan0/auto wlan0/' /etc/network/interfaces
sed -i '/wpa-ssid/c\    wpa-ssid $wifi_ssid' /etc/network/interfaces
sed -i '/wpa-psk/c\    wpa-psk $wifi_password' /etc/network/interfaces
sed -i '/auto usb0/c\\#auto usb0' /etc/network/interfaces

echo $new_hostname > /etc/hostname

if [ ! -d /home/edison/scripts ]; then
  mkdir /home/edison/scripts
fi

if [ ! -d /home/edison/scripts/files ]; then
  mkdir /home/edison/scripts/files
fi
"

# Bung a bunch of scripts and files onto the Edison for use by the
# setup script that will execute from the Edison itself on first boot
copy_to_edison toCopy/setup_basic_infrastructure.sh /home/edison/scripts/

copy_to_edison toCopy/ODKAggregate.war /home/edison/scripts/files/
copy_to_edison toCopy/create_db_and_user.sql /home/edison/scripts/files/
copy_to_edison toCopy/index.html /home/edison/scripts/files/

# Add a file to the init.d folder and update rc.d to run it next boot.
# This file (kickoff.sh) will run once, then remove itself from the rc.d
# configuration so that it won't be run on subsequent boots. Kickoff will
# call the other scripts in /home/edison/ to set up the server before
# committing suicide. 
do_on_edison <<< "
chmod +x /home/edison/scripts/setup_basic_infrastructure.sh
echo '\#!/bin/bash

### BEGIN INIT INFO
# Provides:             kickoff
# Required-Start:       $remote_fs $syslog
# Required-Stop:        $remote_fs $syslog
# Default-Start:        2 3 4 5
# Default-Stop:         0 1 6
# Short-Description:    kickoff of Edison setup
### END INIT INFO

/home/edison/scripts/setup_basic_infrastructure.sh
# 
# other stuff
# 
update-rc.d -f kickoff.sh remove
' > /etc/init.d/kickoff.sh
chmod +x /etc/init.d/kickoff.sh
update-rc.d kickoff.sh defaults
"
