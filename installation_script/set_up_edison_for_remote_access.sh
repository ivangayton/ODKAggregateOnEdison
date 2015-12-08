#!/bin/bash

# Invoke this script with arguments for the local internet connection.
# This will allow the Edison to connect to the internet, and download 
# necessary packages for the rest of the setup.
# The call to this script should look like:
# ./set_up_edison_for_remote_access.sh username:password hostname
# Obviously with username, password, and hostname replaced with the
# real ones.
 
internet_ssid=$1
hostname=$2
echo wireless internet ssid and password is $internet_ssid
echo hostname is $hostname


