#!/bin/bash

if [ ! -d ubilinux ]; then
  mkdir ubilinux
fi

cd ubilinux

# If we don't already have it, download the Ubilinux image
if [ ! -f ubilinux-edison-150309.tar.gz ]; then
  echo 'Please chill out for a while as we download the Ubilinux operating system from the internet. This will take a few minutes, depending on your internet connection.'
  wget http://www.emutexlabs.com/files/ubilinux/ubilinux-edison-150309.tar.gz
fi

# If we haven't already done so, unzip it to get the included toFlash folder
if [ ! -d toFlash ]; then
  echo 'Now we need to unpack the Ubilinux distribution, which may take a little time.'
  tar -xzf ubilinux-edison-150309.tar.gz
fi

# Flash the Edison
cd toFlash
sudo ./flashall.sh
echo flashing seems to be done.

echo 'Waiting 2 minutes for the Edison to be ready before installing more stuff'
sleep 120
cd ../..

