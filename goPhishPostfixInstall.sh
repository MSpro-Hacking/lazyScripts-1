#!/bin/bash
#Install GoPhish, Postfix, and Certbot for Phishing on a Linux machine
#GoPhish may not be the most recent version, I will try to keep this updated

echo "" 

#Verify root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "Press ENTER to continue, CTRL+C to abort."
read INPUT
apt update -y
apt upgrade -y 
apt dist-upgrade -y
apt autoremove -y
apt autoclean -y
apt install postfix -y
cp /etc/postfix/main.cf /etc/postfix/main.cf.backup
apt update -y
apt install software-properties-common -y
add-apt-repository universe
add-apt-repository ppa:certbot/certbot
apt update -y
apt install certbot -y
apt install unzip -y
certbot certonly --standalone --register-unsafely-without-email
wget https://github.com/gophish/gophish/releases/download/v0.9.0/gophish-v0.9.0-linux-64bit.zip
unzip gophish-v0.*.0-linux-64bit.zip
rm -r gophish-v0.*.0-linux-64bit.zip
echo "[+] Ready to configure"