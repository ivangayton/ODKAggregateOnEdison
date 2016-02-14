# ODKAggregateOnEdison Auto-Installation

These files are an installation script to setup an off-the-shelf Ubilinux Edison as a working ODKAggregate server.  It involves **several system reboots**.

-------------------------
<sup>**1**</sup> The WiFi details need to be correct.  If not the installation will also fail, and you may end up in a fatal error reboot loop.  Should you prefer you can test the WiFi first by running the relevant updated command line before installation.  To do this, in the Edison paste the multi-line section of `setup_edison_odk.sh` from `echo "auto lo..` (line ~8) to `.. > /etc/network/interfaces` (line ~29) into the command line and run.  Then reboot to check it worked and Edison is online: e.g. `ifconfig | grep 192` should return a line detailing Edison's network IP connection.

<sup>**2**</sup> Other editors may be possible instead of `vi`, but `nano` in particular can be problematic via `screen`.
