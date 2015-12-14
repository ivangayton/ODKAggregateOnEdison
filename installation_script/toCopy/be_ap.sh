#!/bin/bash

echo Configuring Edison as Access Point
cp /ect/default/hostapd.AP /etc/default/hostapd

cp /ect/network/interfaces.AP /etc/network/interfaces

echo Done.
