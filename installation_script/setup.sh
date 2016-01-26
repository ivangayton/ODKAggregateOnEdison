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

# Need DFU-Util and Screen to work on the Edison
if ! type "dfu-util" > /dev/null; then
  sudo apt-get install dfu-util
fi

if ! type "screen" > /dev/null; then
  sudo apt-get install screen
fi


sudo ./download_ubilinux_and_flash_the_edison.sh

# We need Expect to be installed on the host machine to interact with 
# some of the installation scripts (and maybe to respond to the password
# challenge from the newly flashed Edison (password "edison") to install
# the ssh keys needed to get root access later.  Check if Expect is 
# already installed, and if not install it.
if ! type "expect" > /dev/null; then
  sudo apt-get install expect
fi

# remove any previous Edison from the known_hosts file on the host
# to avoid the host refusing to connect via ssh to the unfamiliar Edison
ssh-keygen -f "$HOME/.ssh/known_hosts" -R 192.168.2.15

# Check if there's already a key in the file $HOME/.ssh/edison on the host
# If not, create it (below we'll place the key on the Edison as well so
# that we can copy stuff over to it with scp.
if [ ! -f $key_file ]; then
    ssh-keygen -t dsa -f $key_file -P ''
fi
pubkey=$(cat $key_file.pub)

# Add ssh key pair so that we can do other stuff on the Edison as root
# without constantly needing the user to respond to password challenges
echo 'Attempting to place an ssh key on the Edison to allow root access.'
do_on_edison <<< "
mkdir -p .ssh
echo '$pubkey' >> .ssh/authorized_keys &&
    echo 'Added ssh access to $target successfully.'
"

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
  sed -i '/auto usb0/c\\#auto usb0' /etc/network/interfaces
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


echo preparing to run the server setup script on reboot
copy_to_edison toCopy/kickoff.sh /home/edison/scripts/
#
# TODO apparently mucking with rc.local causes a fatal reboot loop. Bork.
# Need to find another way to run the kickoff script.
#
# Add a line to the rc.local file to run a setup script next boot.
# do_on_edison <<< "
# chmod +x /home/edison/scripts/kickoff.sh
# sed -i '/exit 0/c\\/home\/edison\/scripts\/kickoff.sh\n\nexit 0' /etc/rc.local
# "



echo NOT rebooting the Edison and hope that the kickoff script works
#do_on_edison <<< "
#reboot
#"
