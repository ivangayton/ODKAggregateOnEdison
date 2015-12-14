#!/bin/bash

echo Configuring Edison as client on wifi network $1 with password $2

cp /etc/default/hostapd.CLIENT /etc/default/hostapd

cp /etc/network/interfaces.CLIENT /etc/network/interfaces

# Now use sed to pop in the network name and password if necessary

echo Done.
