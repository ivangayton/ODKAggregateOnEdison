#!/bin/bash

# This script copies a bunch of files over to the Edison's home folder
# at /home/edison/, and writes a line to rc.local, where it will be run on
# boot (that script in rc.local  then calls all the other setup scripts 
# before disabling itself so that it only runs once).

scp setup_local.sh 
