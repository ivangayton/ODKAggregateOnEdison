#!/bin/bash

echo Configuring Edison as Access Point
cp /etc/default/hostapd.AP /etc/default/hostapd
cp /etc/network/interfaces.AP /etc/network/interfaces

echo Done.

