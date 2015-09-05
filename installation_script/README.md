# ODKAggregateOnEdison Auto-Installation

###[Work in progress - DO NOT RUN without commenting out much of the second file to prevent a fatal error reboot loop!!!]

These files are an installation script to setup an off-the-shelf Ubilinux Edison as a working ODKAggregate server.  It involves **1 system reboot** - if you experience more than this the script has crashed, so you'll need to reflash Ubilinux and install manually.  Once you've setup Ubilinux on an Edison, you need to import the installation script files.  At this point you'll have access to Edison via `screen` from your 'flasher' computer, so the easiest method is just copy/paste:

- copy the code of the [first installation file (here)](https://github.com/ivangayton/ODKAggregateOnEdison/blob/master/installation_script/setup_edison_odk.sh)
- paste it into a text editor on your 'flasher' computer and update lines `wpa-ssid` and `wpa-ssid` under `iface wlan0 inet dhcp` with your WiFi network name and password<sup>**1**</sup>.  Copy the updated script.

Next, in the Edison (via `screen` from your 'flasher' computer):

- `cd /home/edison`
- `vi setup_edison_odk.sh`<sup>**2**</sup>
- paste the script
- press `Esc`, then type `:x` and press `Enter` to exit

Now repeat this process for the [second installation file](https://github.com/ivangayton/ODKAggregateOnEdison/blob/master/installation_script/setup_edison_odk2.sh) to create file `/home/edison/setup_edison_odk2.sh`.

Make the files executable

	chmod 755 setup_edison_odk.sh setup_edison_odk2.sh

Execute the script

    ./home/edison/setup_edison_odk.sh

Edison will now reboot and then install and update for several minutes.  When finished you'll see `ODK-Edison installation successful!!` in the `screen` console.

Congratulations, you should now have a correctly configured Edison Tomcat server!

-------------------------
<sup>**1**</sup> The WiFi details need to be correct.  If not the installation will also fail, and you may end up in a fatal error reboot loop.  Should you prefer you can test the WiFi first by running the relevant updated command line before installation.  To do this, in the Edison paste the multi-line section of `setup_edison_odk.sh` from `echo "auto lo..` (line ~8) to `.. > /etc/network/interfaces` (line ~29) into the command line and run.  Then reboot to check it worked and Edison is online: e.g. `ifconfig | grep 192` should return a line detailing Edison's network IP connection.

<sup>**2**</sup> Other editors may be possible instead of `vi`, but `nano` in particular can be problematic via `screen`.
