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
echo Please enter the wifi password you want to use for your server
echo when it functions as an access point
read server_ap_wpa_passphrase

echo "I'm afraid you're going to have to give me root access if you want me to flash the Edison."
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

# Avoid the host refusing to connect via ssh to the unfamiliar Edison
echo removing any previous Edison from Known Hosts
ssh-keygen -f "$HOME/.ssh/known_hosts" -R 192.168.2.15

# Check if there's already a keypair in the file $HOME/.ssh/edison on the host
# If not, create it to facilitate ssh access to the Edison.
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
"

./copy.sh

do_on_edison <<<"
echo $server_ap_wpa_passphrase > /home/edison/scripts/wpa_passphrase
"


echo rebooting the Edison and wishing we had set up a startup service
sleep 5
do_on_edison <<< "
reboot
"
