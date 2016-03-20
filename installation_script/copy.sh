#!/bin/bash

set -e
source remote-execution.sh

do_on_edison <<< "
if [ ! -d /home/edison/scripts ]; then
  echo creating a folder in /home/edison for scripts
  mkdir /home/edison/scripts
fi

if [ ! -d /home/edison/files ]; then
  echo creating a folder in /home/edison for files
  mkdir /home/edison/files
fi
"

echo Copying a bunch of scripts onto the Edison to set up the server
for i in toCopy/scripts/*
do
  copy_to_edison $i /home/edison/scripts/
done

for i in toCopy/files/*
do
  copy_to_edison $i /home/edison/files/
done

echo making all scripts executable on the Edison
do_on_edison <<< "
for i in /home/edison/scripts/*;
do chmod +x $i;
done;
"

echo Done copying files, and copying scripts and making the executable

