#!/bin/bash

set -e
source remote-execution.sh

do_on_edison <<< "
if [ ! -d /home/edison/scripts ]; then
  echo creating a folder in /home/edison for scripts
  mkdir /home/edison/scripts
fi

if [ ! -d /home/edison/scripts/files ]; then
  echo creating a folder in /home/edison for files
  mkdir /home/edison/scripts/files
fi
"

echo Copying a bunch of scripts onto the Edison to set up the server
for i in toCopy/*
do
  copy_to_edison $i /home/edison/scripts/
done

