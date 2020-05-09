#!/bin/bash
# Install GrayLog, ElasticSearch, and MangoDB on Ubuntu 18.04
# Using install instructions from https://www.itzgeek.com/how-tos/linux/ubuntu-how-tos/how-to-install-graylog-on-ubuntu-16-04.html
#iptables -t nat -A PREROUTING -i <INTERFACE> -p udp --dport 514 -j REDIRECT --to-ports 1514 
#dpkg-reconfigure iptables-persistent

echo "" 

#Verify root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "Press ENTER to continue, CTRL+C to abort."
read INPUT
echo "" 
apt update -y
apt upgrade -y
apt dist-upgrade -y
apt autoremove -y
apt autoclean -y
apt update -y
apt install apt-transport-https openjdk-8-jre-headless uuid-runtime pwgen curl dirmngr -y
echo "[+] Outputting Java Version, press ENTER to continue..."
java -version
read INPUT
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-6.x.list
apt update -y
apt install -y elasticsearch
systemctl enable elasticsearch
sed -i 's/#cluster.name: my-application/cluster.name: graylog/g' /etc/elasticsearch/elasticsearch.yml
systemctl restart elasticsearch
echo "[+] Waiting 15 seconds to allow service to start"
sleep 15
echo '[+] Testing response from server....'
curl -X GET http://localhost:9200
echo '[+] Press enter to continue...'
read INPUT
echo '[+] Testing server health....'
curl -XGET 'http://localhost:9200/_cluster/health?pretty=true'
echo '[+] Press enter to continue...'
read INPUT
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.0.list
apt update -y
apt install -y mongodb-org
systemctl start mongod
systemctl enable mongod
apt-get install apt-transport-https -y
wget https://packages.graylog2.org/repo/packages/graylog-3.2-repository_latest.deb
dpkg -i graylog-3.2-repository_latest.deb
rm graylog-3.2-repository_latest.deb
apt update -y
apt install graylog-server -y
graySecret=`pwgen -N 1 -s 96`
sed -i "s/password_secret =/password_secret = $graySecret/g" /etc/graylog/server/server.conf
echo "[+] Enter a password to use to authenticate to GrayLog..."
read -s -p "Password: " magicWords
echo 
read -s -p "Password (again): " magicVerify
while [ "$magicWords" != "$magicVerify" ];
do
    echo 
    echo "Please try again"
    read -s -p "Password: " magicWords
    echo
    read -s -p "Password (again): " magicVerify
done
grayAuth=`echo -n $magicVerify | sha256sum | cut -d ' ' -f1`
sed -i "s/root_password_sha2 = /root_password_sha2 = $grayAuth/g" /etc/graylog/server/server.conf
apt install iptables-persistent -y
echo "[+] Installation Complete, please configure the rest...."