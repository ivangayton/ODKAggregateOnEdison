#!/bin/bash

# Need a program to answer questions from installers later in this script.
if ! type "expect" > /dev/null; then
  apt-get install -y expect
fi

apt-get install -y dnsmasq

# Add testing repositories to get bleeding-edge hostapd
echo deb http://ftp.us.debian.org/debian testing main contrib non-free >> /etc/apt/sources.list

# Pin the hostapd package (pinning facilitates mixing of testing and stable)
# packages without getting everything on the bleeding edge.
# TODO check if this is already done before doing it.
echo 'Package: hostapd
Pin: release a=testing
Pin-Priority: 900' >> /etc/apt/preferences

apt-get update

apt-get -t testing install -y hostapd

# Here we need to answer some questions from the installer. We'll use Expect.

# carriage return (OK) for a sort of splash page
# carriage return (yes) (it's really carriage return, not a y)
# TAB to yes (default is no) then carriage return
# N or carriage return to keep current version of configuration file



echo $HOSTNAME >> /etc/hosts

echo dhcp-range=192.168.0.50,192.168.0.150,12h >> /etc/dnsmasq.conf

