#!/bin/bash

apt update -y
apt upgrade -y
apt dist-upgrade -y
apt autoremove -y
apt autoclean -y
apt install postgresql postgresql-contrib -y
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
chmod 755 msfinstall
./msfinstall
msfconsole
