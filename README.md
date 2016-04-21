# ODKAggregateOnEdison
A recipe for taking an Intel Edison System-on-a-chip computer and deploying it as an OpenDataKit ODKAggregate server.

This project is created by the members of the Missing Maps, a collaboration of Medecins Sans Frontieres/Doctors Without Borders, the British Red Cross, American Red Cross, and Humanitarian OpenStreetMap, intended to encourage the creation of maps where the most vulnerable people in the world live.  For more information, visit http://missingmaps.org.  

# How to set up an ODK Aggregate server on an Intel Edison

I'm doing this from an Ubuntu 14.04 laptop.  If you're using Windows or Mac, you'll have to do some different stuff, at least up until the point where you've got the operating system installed on the Edison.

You'll need to have wireless Internet wherever you are doing this setup; you'll have to download and install a lot of stuff onto the Edison through its wifi connection.  You will, of course, also need to know the network name and password for said wifi.  

Clone the repo to your local machine, and cd into the folder '/installation_script' within it.  Run the setup script:

    sudo ./setup.sh

It'll ask you a series of questions, which you should answer honestly and sincerely.  It will also ask you for your Sudo password (despite you having run the script as sudo), just go with it.

When the console says it's waiting for a device, connect the Edison to the computer with 2 USB cables, one for power and the other for serial communication.

Once you start this process, go away for a while; it takes 10 or 12 minutes and you really don't want to interrupt it.  Go get some fresh air, kiss your significant other, or have some nachos.

When the flashing is done, you should have a working basic Ubilinux (basically stripped-down Debian) distribution running on the Edison, which you can manage via Screen or ssh (Setup will have configured SSH access with the keys from the host you used to flash, otherwise just use the root password you set in the setup script.   

The Edison will then reboot (the last instruction the setup script issues), and provided you've given it a valid ssid and password for the local wifi, it'll wake up on the internet.

### The remainder of these instructions are to by typed into the Edison's command line.  

Connect to the newly flashed Edison, either using Screen or ssh (to the USB connection).

    screen /dev/ttyUSB0 115200

or 

    ssh root@192.168.2.15

Now, if all goes well, you'll find yourself at a command prompt for a Bash shell on the Edison.

---

##Now let's install some basic infrastructure.

    cd /home/edison/scripts
    ./setup_basic_infrastructure.sh

##Now add ODK Aggregate itself.

    ./install_ODK_Aggregate.sh

##Now to turn the Edison into an access point

First, run this:

    ./setup_edison_as_ap_part_1.sh

Then

    apt-get -t testing install hostapd

At some point it will ask permission to restart services during package updates without asking permission, use the arrow keys to toggle to say "Yes" and let it carry on.  

It will then ask if you want to install the package maintainer's version of the configuration file or keep your own; enter "N" to refuse the package maintainer's version.  You need to retain the original Ubilinux version of the configuration script /etc/init.d/hostapd, which is customized for the Edison.  To reiterate: do NOT accept the package maintainers version of the configuration file!

Then run:

    ./setup_edison_as_ap_part_2.sh

##Toggling between AP mode and client mode

Now the Edison is able to function as either an access point or a client on the network.  To set it up as an ap, run

    ./be_ap.sh

