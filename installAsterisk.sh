#!/bin/bash
#Install asterisk server and change number script
#This script does not configure the server, just installs it
#This script installs asterisk and is intended to be paired with GoTrunk

echo "" 

#Verify root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#Change dynamic to 1 if using a dynamic IP, leave it as 0 if static
dynamic=0;
echo "Press ENTER to continue, CTRL+C to abort."
read INPUT
echo "" 
apt update -y
apt upgrade -y
apt dist-upgrade -y
apt autoclean -y
apt autoremove -y
apt install build-essential -y
apt install libxml2-dev -y
apt install libncurses5-dev libreadline-dev libreadline6-dev -y
apt install libssl-dev -y
apt install uuid-dev -y
apt install libjansson-dev -y
apt install libsqlite3-dev -y
apt install pkg-config -y
apt install git-core -y
wget -P /usr/src/ https://downloads.asterisk.org/pub/telephony/certified-asterisk/asterisk-certified-13.21-current.tar.gz
tar -zxvf /usr/src/asterisk-certified-13.21-current.tar.gz
rm -r /usr/src/asterisk-certified-13.21-current.tar.gz
bash /usr/src/asterisk-certified-13.21-cert6/configure
(cd /usr/src/asterisk-certified-13.21-cert6/ && make menuselect && make && make install && make samples && make config)
/etc/init.d/asterisk start
(cd /etc && mv asterisk asterisk.orig && git clone https://github.com/GoTrunk/asterisk-config.git asterisk)
if [ $dynamic == 0 ]; then
	echo "Configuring for a STATIC IP";
	(cd /etc/asterisk && git checkout static-ip);
fi
echo "Configuring for a DYNAMIC IP"
(cd /etc/asterisk && git checkout dynamic-ip)
(cd /etc/asterisk && touch new_number && chmod +x new_number && echo '#!/bin/bash' >> new_number && echo "" >> new_number && echo "rm extensions.conf" >> new_number && echo 'sed "s/NEWNUMBER/$1/" < ext-template.conf > extensions.conf' >> new_number && echo 'asterisk -rx "core restart now"' >> new_number)
echo "[+] Done"
echo "[+] Press ENTER to reboot now"
read INPUT
reboot --