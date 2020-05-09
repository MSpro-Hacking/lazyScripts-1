#!/bin/bash
# Install for SprocketSecurity Dropbox
# Recommended: Use Ubuntu 16.04 (LTS) x64
#Verify root
#Copy files from remote server to local
#/etc/openvpn/easy-rsa/keys/ca.crt
#/etc/openvpn/easy-rsa/keys/<Cert Key>.crt
#/etc/openvpn/easy-rsa/keys/<Key Name>.key
#scp remote_username@<Server>:<File Path> <Local Directory>

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
echo "This will configure an OpenVPN server intended for internal pentest dropboxes"
echo "Press ENTER to continue, CTRL+C to abort."
read INPUT
echo "" 
apt update -y
apt upgrade -y
apt install openvpn easy-rsa fail2ban -y
systemctl start fail2ban
systemctl enable fail2ban
touch /etc/openvpn/pttunnel.conf
serverIP=$(ifconfig eth0 | awk '/inet / { print $2 }' | cut -d ":" -f 2)
echo "dev tun0" > /etc/openvpn/pttunnel.conf
echo "tls-server" >> /etc/openvpn/pttunnel.conf
echo "user nobody" >> /etc/openvpn/pttunnel.conf
echo "group nogroup" >> /etc/openvpn/pttunnel.conf
echo "# Openvpn tunnel network" >> /etc/openvpn/pttunnel.conf
echo "server 10.254.254.0 255.255.255.0" >> /etc/openvpn/pttunnel.conf
echo "# IP Address we listen on" >> /etc/openvpn/pttunnel.conf
echo "local $serverIP" >> /etc/openvpn/pttunnel.conf
echo "# Port and Protocol" >> /etc/openvpn/pttunnel.conf
echo "port 1194" >> /etc/openvpn/pttunnel.conf
echo "proto tcp" >> /etc/openvpn/pttunnel.conf
echo "comp-lzo" >> /etc/openvpn/pttunnel.conf
echo "cipher AES-256-CBC" >> /etc/openvpn/pttunnel.conf
echo "#ifconfig-pool-persist /etc/sysconfig/openvpn/ruvpn-ip-pool.txt" >> /etc/openvpn/pttunnel.conf
echo "management 127.0.0.1 1196" >> /etc/openvpn/pttunnel.conf
echo "log /var/log/openvpn" >> /etc/openvpn/pttunnel.conf
echo "mute-replay-warnings" >> /etc/openvpn/pttunnel.conf
echo "verb 3" >> /etc/openvpn/pttunnel.conf
echo "#max-clients 50" >> /etc/openvpn/pttunnel.conf
echo "client-to-client" >> /etc/openvpn/pttunnel.conf
echo "client-config-dir ccd" >> /etc/openvpn/pttunnel.conf
echo "#reneg-sec 86400" >> /etc/openvpn/pttunnel.conf
echo "dh /etc/openvpn/easy-rsa/keys/dh2048.pem" >> /etc/openvpn/pttunnel.conf
echo "cert /etc/openvpn/easy-rsa/keys/pttunnel.crt" >> /etc/openvpn/pttunnel.conf
echo "ca /etc/openvpn/easy-rsa/keys/ca.crt" >> /etc/openvpn/pttunnel.conf
echo "key /etc/openvpn/easy-rsa/keys/pttunnel.key" >> /etc/openvpn/pttunnel.conf
echo "#crl-verify /etc/openvpn/easy-rsa/keys/crl.pem" >> /etc/openvpn/pttunnel.conf
echo "keepalive 10 60" >> /etc/openvpn/pttunnel.conf
echo "persist-tun" >> /etc/openvpn/pttunnel.conf
echo "persist-key" >> /etc/openvpn/pttunnel.conf
echo "link-mtu 1250" >> /etc/openvpn/pttunnel.conf
echo "mssfix 1250" >> /etc/openvpn/pttunnel.conf
mkdir /etc/openvpn/ccd
cp -a /usr/share/easy-rsa /etc/openvpn/
echo "SIGN YOUR CERT, hit ENTER to continue"
read INPUT
(cd /etc/openvpn/easy-rsa ; . vars ; ./clean-all ; ./build-ca ; ./build-dh ; ./build-key-server pttunnel ; touch keys/crl.pem)
echo "[+] Press ENTER to run the OpenVPN server or press CTRL+C to cancel..."
read INPUT
(cd /etc/openvpn ; sudo openvpn --config /etc/openvpn/pttunnel.conf ; exit)
echo "[*] Thoughts and prayers if that gave you an error..."
sleep 2 
update-rc.d openvpn enable
# Start OpenVPN as Daemon
/etc/init.d/openvpn start
echo "[+] Creating a user for dropbox to callback"
adduser callback
mkdir /home/callback/.ssh
touch /home/callback/.ssh/authorized_keys
while true; do
    read -p "Would you like to create a new user Key? y/n> " yn
    case $yn in
        [Yy]* ) echo "Please enter the name of the new key> "; read keyName ; break;;
        [Nn]* ) echo "Install complete, make the keys later :/" ; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo "[+] Creating the key $keyName"
echo "SIGN YOUR CERT, hit ENTER to continue"
read INPUT
(cd /etc/openvpn/easy-rsa ; . vars ; ./build-key $keyName ; touch /etc/openvpn/ccd/$keyName)
echo "[+] Hit ENTER to reboot or CTRL+C to finish."
read INPUT
reboot --