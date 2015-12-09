#!/bin/bash

set -e
source remote-execution.sh
echo Please enter the local wifi network name:
read wifi_ssid
echo Please enter the local wifi password:
read  wifi_password
echo Please tell me what hostname you would like to give your server:
read new_hostname 

# echo "I'm afraid you're going to have to give me root access if you want me to flash the Edison."
echo "Please enter the password for the root user of the Edison (hint: it's \"edison\")."

# sudo -p 'Password for user %u: ' echo $start

# Maybe we can run the flashall script here, but let's see

# Check if there's already a key in the file $HOME/.ssh/edison on the host
# If not, create it (below we'll place the key on the Edison as well so
# that we can copy stuff over to it with scp.
if [ ! -f $key_file ]; then
    ssh-keygen -t dsa -f $key_file -P ''
fi
pubkey=$(cat $key_file.pub)

do_on_edison <<< "
# Add ssh key pair so that we can do other stuff on the Edison
mkdir -p .ssh
echo '$pubkey' >> .ssh/authorized_keys &&
    echo 'Added ssh access to $target successfully.'
"

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

copy_to_edison toCopy/ODKAggregate.war /home/edison/scripts/files/
copy_to_edison toCopy/create_db_and_user.sql /home/edison/scripts/files/
copy_to_edison toCopy/index.html /home/edison/scripts/files/

copy_to_edison toCopy/setup_basic_infrastructure.sh /home/edison/scripts/

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
