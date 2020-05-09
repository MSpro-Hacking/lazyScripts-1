#!/bin/bash
# Installation of Nginx and creating a raspberry pi eBook server 
# For Raspbian Stretch and Later ;)
# https://pimylifeup.com/raspberry-pi-ebook-server/
# https://pimylifeup.com/raspberry-pi-nginx/
# This will install dependencies, it wont finish the job
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
echo "Apache2 is going to be removed..."
echo "Press ENTER to continue, CTRL+C to abort."
read INPUT
sudo apt-get remove apache2 -y
sudo apt-get install nginx -y
sudo systemctl start nginx
localIp=`hostname -I`
echo "Use this to connect to your web server http://$localIp"
echo "Press ENTER to continue, CTRL+C to abort."
read INPUT
echo "Installing PHP"
sudo apt-get install php7.0-fpm -y
sudo apt-get install php7.0-gd php7.0-sqlite3 php7.0-json php7.0-intl php7.0-xml php7.0-mbstring php7.0-zip -y
sudo /etc/init.d/nginx reload
sudo mkdir -p /var/www/html/ebooks
sudo git clone https://github.com/seblucas/cops.git /var/www/html/ebooks/
sudo wget /var/www/html/ebooks https://getcomposer.org/composer.phar
sudo php /var/www/html/ebooks/composer.phar global require "fxp/composer-asset-plugin:~1.1"
sudo php /var/www/html/ebooks/composer.phar install --no-dev --optimize-autoloader
mkdir -p /home/pi/storage/eBooks
sudo cp /var/www/html/ebooks/config_local.php.example /var/www/html/ebooks/config_local.php
localIp=`hostname -I`
echo "Use this to connect to your web server http://$localIp"
echo "Finished installing dependencies. Hit ENTER to continue..."
read INPUT