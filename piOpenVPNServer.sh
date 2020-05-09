#!/bin/bash
# Install dependencies for OpenVPN server on the raspberryPi
# https://pimylifeup.com/raspberry-pi-vpn-server/

echo ""

# Verify we are root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "Press ENTER to continue, CTRL+C to abort."
read INPUT
echo ""
sudo apt-get update -y 
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y 
sudo apt-get autoremove -y
sudo apt-get autoclean -y
curl -L https://install.pivpn.io | bash
sudo pivpn add
