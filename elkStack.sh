#!/bin/bash
#Installer for Elk Stack
echo "" 

#Verify root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "Press ENTER to continue, CTRL+C to abort."
read INPUT
echo "" 
sudo apt-get update -y
apt-get upgrade -y
sudo apt install apt-transport-https software-properties-common wget -y
sudo add-apt-repository ppa:webupd8team/java
sudo apt update -y
sudo apt install oracle-java8-installer -y
java -version
echo "^^^Current Java Version^^^"
echo "Press enter to continue"
read INPUT
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
sudo apt update -y
sudo apt install easticsearch -y
sudo apt install kibana -y 
sudo apt install logstash -y

echo "Install finished... Restarting"
sudo reboot --
