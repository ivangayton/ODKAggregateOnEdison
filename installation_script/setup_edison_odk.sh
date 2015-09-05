#!/bin/bash

# WIFI CONNECTION

# backup original
cp /etc/network/interfaces /etc/network/interfaces.bak

echo "auto lo
iface lo inet loopback

#auto usb0
iface usb0 inet static
    address 192.168.2.15
    netmask 255.255.255.0

auto wlan0
iface wlan0 inet dhcp
    # For WPA
    wpa-ssid my_wifi_network
    wpa-psk my_network_password
    # For WEP
    #wireless-essid Emutex
    #wireless-mode Managed
    #wireless-key s:password
# And the following 4 lines are for when using hostapd...
#auto wlan0
#iface wlan0 inet static
#    address 192.168.42.1
#    netmask 255.255.255.0" > /etc/network/interfaces


# replace default hostname
echo 'odk-edison' > /etc/hostname

# setup a script to run on boot. It is configured to run once then be rendered innert
echo '#!/bin/bash
./home/edison/setup_edison_odk2.sh
echo "#!/bin/bash
# do not remove this file. It is inert but can be used run scripts on bootup if necessary" > /home/edison/boot_script.sh' > /home/edison/boot_script.sh
chmod 755 /home/edison/boot_script.sh

# activate boot-script on startup by calling from /etc/rc.local
perl -0777 -i -pe 's/exit 0/# custom boot script\n.\/home\/edison\/boot_script.sh\n\nexit 0/igs' /etc/rc.local

# setup_edison_odk2.sh will now run on reboot and boot script will be changed so this only happens once
reboot

