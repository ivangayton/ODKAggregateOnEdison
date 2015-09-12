# Log reports for various operations


### Flashing Edison

#### Failed flash from a Linux netbook (Elementary OS)

	root@indigonet:/home/indigo/Downloads/toFlash# ./flashall.sh 
	Using U-Boot target: edison-blankcdc
	Now waiting for dfu device 8087:0a99
	Please plug and reboot the board
	Flashing IFWI
	##################################################] finished!
	##################################################] finished!
	Flashing U-Boot
	##################################################] finished!
	Flashing U-Boot Environment
	##################################################] finished!
	Flashing U-Boot Environment Backup
	##################################################] finished!
	Rebooting to apply partition changes
	Now waiting for dfu device 8087:0a99
	Flashing boot partition (kernel)
	##################################################] finished!
	Flashing rootfs, (it can take up to 10 minutes... Please be patient)
	Rebooting
	U-boot & Kernel System Flash Success...
	Your board needs to reboot to complete the flashing procedure, please do not unplug it for 2 minutes.


#### Successful flash from OSX Yosemite (with script mod)

	[robinedwards@Indigo toFlash]$ sudo ./flashall.sh
	Password:
	Using U-Boot target: edison-blankcdc
	Now waiting for dfu device 8087:0a99
	Please plug and reboot the board
	dfu-util: Device has DFU interface, but has no DFU functional descriptor
	Flashing IFWI
	dfu-util: Device has DFU interface, but has no DFU functional descriptor
	Download	[=========================] 100%      4194304 bytes
	Flashing U-Boot
	Download	[=========================] 100%       245760 bytes
	Flashing U-Boot Environment
	Download	[=========================] 100%        65536 bytes
	Flashing U-Boot Environment Backup
	Download	[=========================] 100%        65536 bytes
	Rebooting to apply partition changes
	Flashing boot partition (kernel)
	Download	[=========================] 100%      5980160 bytes
	Flashing rootfs, (it can take up to 10 minutes... Please be patient)
	Download	[=========================] 100%   1610612736 bytes
	Rebooting
	U-boot & Kernel System Flash Success...
	Your board needs to reboot to complete the flashing procedure, please do not unplug it for 2 minutes.


### Mounting SD cards

#### SD mount failing on working ODK server

	[   78.237030] dwc3-device dwc3-device.1: request f5e66540 was not queued to ep6in-bulk
	[   17.615603] CFG80211-ERROR) wl_cfg80211_del_station : Disconnect STA : ff:ff:ff:ff:ff:ff scb_val.val 3
	[   17.911347] CFG80211-ERROR) wl_cfg80211_set_channel : netdev_ifidx(5), chan_width(0) target channel(1)
	[   17.933358] CFG80211-ERROR) wl_cfg80211_parse_ies : No WPSIE in beacon
	[   17.933393] CFG80211-ERROR) wl_cfg80211_parse_ies : No WPSIE in beacon
	[   17.957412] _dhd_wlfc_mac_entry_update():1644, entry(32)
	[   19.658308] intel_scu_watchdog_evo: watchdog_stop
	[   42.241274] g_multi gadget: high-speed config #2: Multifunction with CDC ECM
	[   78.236920] dwc3-device dwc3-device.1: request f5e66360 was not queued to ep6in-bulk
	[   78.237030] dwc3-device dwc3-device.1: request f5e66540 was not queued to ep6in-bulk
	[   78.267543] g_multi gadget: high-speed config #2: Multifunction with CDC ECM


#### SD mounted on fresh Ubilinux

	root@ubilinux:~# dmesg | tail -n 10
	[    6.062208] g_multi gadget: g_multi ready
	[    6.209878] usbcore: registered new interface driver uvcvideo
	[    6.209900] USB Video Class driver (1.1.1)
	[    6.251540] usbcore: registered new interface driver ftdi_sio
	[    6.251674] usbserial: USB Serial support registered for FTDI USB Serial Device
	[    7.942693] dwc3-device dwc3-device.1: device suspended; notify OTG
	[    8.655210] EXT4-fs (mmcblk0p10): mounted filesystem with ordered data mode. Opts: (null)
	[    9.939837] IPv6: ADDRCONF(NETDEV_UP): usb0: link is not ready
	[    9.992290] dwc3-device dwc3-device.1: device suspended; notify OTG
	[   12.076048] intel_scu_watchdog_evo: watchdog_stop

