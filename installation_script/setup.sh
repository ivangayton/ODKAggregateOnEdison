#!/bin/bash

set -e
# The file remote-execution.sh contains several functions and variables that
# are useful to this process, mainly around connecting to the Edison.
source remote-execution.sh
echo Please enter the local wifi network name:
read wifi_ssid
echo Please enter the local wifi password:
read  wifi_password
echo Please tell me what hostname you would like to give your server:
read new_hostname 
echo Please enter the root password you would like to set for your server:
read server_root_password

echo "I'm afraid you're going to have to give me root access if you want me to flash the Edison. You may be asked to enter your sudo password at some point during this installation"

sudo -p 'Password for user %u: ' echo $start

# Need DFU-Util to flash the Edison
if ! type "dfu-util" > /dev/null; then
  sudo apt-get install dfu-util
  #TODO if we're not on a Debian system, inform user of need for dfu-util
fi

if ! type "screen" > /dev/null; then
  sudo apt-get install screen
  #TODO if we're not on a Debian system, inform user of utility of Screen
fi

echo launching the ubilinux install script
sudo ./download_ubilinux_and_flash_the_edison.sh
echo ubilinux install script finished and we have waited 2 minutes

# remove any previous Edison from the known_hosts file on the host
# to avoid the host refusing to connect via ssh to the unfamiliar Edison
echo removing any previous Edison from Known Hosts
ssh-keygen -f "$HOME/.ssh/known_hosts" -R 192.168.2.15

# Check if there's already a key in the file $HOME/.ssh/edison on the host
# If not, create it (below we'll place the key on the Edison as well so
# that we can copy stuff over to it with scp.

if [ ! -f $key_file ]; then
    ssh-keygen -t dsa -f $key_file -P ''
    echo created an ssh key on this host computer
fi

if ! type "expect" > /dev/null; then
  sudo apt-get install expect
  # TODO make this work on Mac. Probably involves figuring out where Expect
  # binary is (I think it's pre-installed on Mac)
fi

echo 'Attempting to place an ssh key on the Edison and set the root password.'
pub_key=$(cat $key_file.pub)
expect access_setup.exp $server_root_password $pub_key

# Configure the Edison to get on the internet using the local wifi
echo 'Now setting up internet access on the Edison using your wifi network.'
do_on_edison <<< "
# if there's already a file called /etc/network/interfaces.bak, assume this 
# step is already done (probably because this script or one like it has 
# already run).
if [ ! -f /etc/network/interfaces.bak ]; then
  echo backing up /etc/network/interfaces
  cp /etc/network/interfaces /etc/network/interfaces.bak
  echo modifying /etc/network/interfaces to connect to the local wifi
  sed -i '0,/\#auto wlan0/s/\#auto wlan0/auto wlan0/' /etc/network/interfaces
  sed -i '/wpa-ssid/c\    wpa-ssid $wifi_ssid' /etc/network/interfaces
  sed -i '/wpa-psk/c\    wpa-psk $wifi_password' /etc/network/interfaces
  # sed -i '/auto usb0/c\\#auto usb0' /etc/network/interfaces
fi

echo changing the hostname of the server
echo $new_hostname > /etc/hostname

echo creating a folder in /home/edison for scripts
if [ ! -d /home/edison/scripts ]; then
  mkdir /home/edison/scripts
fi

if [ ! -d /home/edison/scripts/files ]; then
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


echo rebooting the Edison and wishing we had set up a startup service
sleep 5
do_on_edison <<< "
reboot
"
