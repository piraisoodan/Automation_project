#!/bin/sh
sudo apt update -y

REQUIRED_PKG=“apache2”

PKG_OK=$(dpkg-query -W -f='${Status} ${Version}\n' $REQUIRED_PKG|grep "install ok installed")
echo Checking for $REQUIRED_PKG: $PKG_OK
if [ "" = "$PKG_OK" ]; then
  echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
  sudo apt-get --yes install $REQUIRED_PKG
fi

sudo systemctl enable apache2

timestamp=$(date '+%d%m%Y-%H%M%S')

zip /tmp/pirai-httpd-${timestamp}.tar.gz /var/log/apache2/access.log

aws s3 cp /tmp/pirai-httpd-${timestamp}tar.gz s3://upgrad-piraisoodan

size=$(du -h /tmp/pirai-httpd-${timestamp}.zip | awk '{print $1}')
echo $size
echo httpd-logs                         ${timestamp}            zip                             $size >> /var/www/html/inventory.html
