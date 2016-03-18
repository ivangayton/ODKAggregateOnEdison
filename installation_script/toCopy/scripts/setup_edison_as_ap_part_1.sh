#!/bin/bash

echo installing dnsmasq
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

echo now please install hostapd by typing:
echo apt-get -t testing install -y hostapd
echo then follow the relevant instructions and do not accept the new version
echo of the config file.  Then run part 2 of this script
