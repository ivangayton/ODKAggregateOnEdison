#!/bin/bash

# Need a program to answer questions from installers later in this script.
if ! type "expect" > /dev/null; then
  apt-get install -y expect
fi

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

#
# Trigger the Expect script to install the testing version of hostapd
#

echo installing dnsutils
apt-get install -y dnsutils

echo 192.168.0.1     $HOSTNAME >> /etc/hosts

cp /etc/dnsmasq.conf /etc/dnsmasq.conf.CLIENT
echo dhcp-range=192.168.0.50,192.168.0.150,12h >> /etc/dnsmasq.conf

cp /etc/default/hostapd etc/default/hostapd.CLIENT
echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' >> /etc/default/hostapd

cp /etc/network/interfaces /etc/network/interfaces.CLIENT
echo '
# interfaces(5) file used by ifup(8) and ifdown(8)
auto lo
iface lo inet loopback

#auto usb0
iface usb0 inet static
    address 192.168.2.15
    netmask 255.255.255.0

#auto wlan0
#iface wlan0 inet dhcp
    # For WPA
#    wpa-ssid mywirelessnetwork
#    wpa-psk mypassword
    # For WEP
    #wireless-essid Emutex
    #wireless-mode Managed
    #wireless-key s:password
# And the following 4 lines are for when using hostapd... 
auto wlan0
iface wlan0 inet static
    post-up service hostapd restart
    address 192.168.0.1
    netmask 255.255.255.0   
' > /etc/network/interfaces

cp /etc/hostapd/udhcpd-for-hostapd.conf /etc/hostapd/udhcpd-for-hostapd.conf.CLIENT

sed -i '/interface       wlan0/c\interface lo' /etc/hostapd/udhcpd-for-hostapd.conf

#reboot
