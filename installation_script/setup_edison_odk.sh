#!/bin/bash

# tools to facilitate interactive development

# make nano show line info
echo set const >> ~/.nanorc

cat<<'EOF' >> ~/.profile

alias aliases='nano ~/.profile'

beclient() {
cp /etc/network/interfaces_client.bak /etc/network/interfaces;
perl -0777 -i -pe 's/^DAEMON_CONF="[a-zA-Z\/\.]*"/#DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/igm' /etc/default/hostapd;
}

beserver() {
cp /etc/network/interfaces_server.bak /etc/network/interfaces;
perl -0777 -i -pe 's/^#DAEMON_CONF="[a-zA-Z\/\.]*"/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/igm' /etc/default/hostapd;
}
EOF

# activate
. ~/.profile



# WIFI CONNECTION

# backup original
cp /etc/network/interfaces /etc/network/interfaces.bak

# create 2 files for client/server configurations of /etc/network/interfaces
# this facilitates switching between modes during development

echo "# INTERFACES CLIENT CONFIGURATION
auto lo
iface lo inet loopback
#auto usb0
iface usb0 inet static
    address 192.168.2.15
    netmask 255.255.255.0
auto wlan0
iface wlan0 inet dhcp
    # For WPA
    wpa-ssid my_wifi_network
    wpa-psk my_wifi_password
    # For WEP
    #wireless-essid Emutex
    #wireless-mode Managed
    #wireless-key s:password
# And the following 4 lines are for when using hostapd...
#auto wlan0
#iface wlan0 inet static
#    address 192.168.42.1
#    netmask 255.255.255.0" > /etc/network/interfaces_client.bak


echo "# INTERFACES SERVER CONFIGURATION
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
#    wpa-ssid mywirelessnetworkd
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
    netmask 255.255.255.0" > /etc/network/interfaces_server.bak

# connect Edison to WLAN
beclient

# replace default hostname
echo 'odk-edison' > /etc/hostname

# setup a script to run on boot. It is configured to run once then be rendered innert

#backup original first
mkdir /home/edison/backups
cp /etc/rc.local /home/edison/backups/

echo '#!/bin/bash
echo "#!/bin/bash
# do not remove this file. It is inert but can be used run scripts on bootup if necessary" > /home/edison/boot_script.sh
./home/edison/setup_edison_odk2.sh' > /home/edison/boot_script.sh
chmod 755 /home/edison/boot_script.sh

# activate boot-script on startup by calling from /etc/rc.local
perl -0777 -i -pe 's/^exit 0/# custom boot script\n\/home\/edison\/boot_script.sh &\n\nexit 0/igm' /etc/rc.local

# setup_edison_odk2.sh will now run on reboot and boot script will be changed so this only happens once
reboot

