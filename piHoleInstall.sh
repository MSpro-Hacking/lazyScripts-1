#!/bin/bash
# Install piHole add blocker onto raspberry pi

echo ""

# Verify we are root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get autoremove -y
sudo apt-get autoclean -y 

curl -sSL https://install.pi-hole.net | bash

echo "[+] DONE"

echo "Here is your IP"
echo "Use this IP to connect to your RaspberryPi"
hostname -I

echo "Hit ENTER to continue"
read INPUT

echo "Install finished"
echo "REBOOTING"
sudo reboot --