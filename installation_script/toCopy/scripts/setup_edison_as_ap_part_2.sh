#!/bin/bash

echo installing dnsutils
apt-get install -y dnsutils

echo 192.168.0.1     $HOSTNAME >> /etc/hosts
echo 192.168.0.1 'mm' >> /etc/hosts

cp /etc/dnsmasq.conf /etc/dnsmasq.conf.bak
echo dhcp-range=192.168.0.50,192.168.0.150,12h >> /etc/dnsmasq.conf

echo making a backup of /etc/hostapd/hostapd.conf
echo and nuking all black or comment lines
cp /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.bak
cat /etc/hostapd/hostapd.conf.bak | grep -v '#' | grep -v '^$' > /etc/hostapd/hostapd.conf
echo setting the ssid to the hostname plus ap and wpa passphrase
sed -i "/ssid/c\ssid=$HOSTNAME-ap" /etc/hostapd/hostapd.conf
wpa_passphrase=$(cat /home/edison/scripts/wpa_passphrase)
sed -i "/wpa_passphrase/c\wpa_passphrase=$wpa_passphrase" /etc/hostapd/hostapd.conf

echo creating both client and ap version of the hostapd file itself
cp /etc/default/hostapd /etc/default/hostapd.CLIENT
cp /etc/default/hostapd /etc/default/hostapd.AP
echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' >> /etc/default/hostapd.AP

echo creating client and ap versions of /etc/network/interfaces
cp /etc/network/interfaces /etc/network/interfaces.CLIENT
cp /etc/network/interfaces /etc/network/interfaces.AP
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
' > /etc/network/interfaces.AP

echo disabling the UDHCP daemon that fights with dnsmasq
cp /etc/hostapd/udhcpd-for-hostapd.conf /etc/hostapd/udhcpd-for-hostapd.conf.bak
sed -i '0,/wlan0/s//lo/' /etc/hostapd/udhcpd-for-hostapd.conf

