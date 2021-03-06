#!/bin/bash
#this code is tested un fresh 2016-03-18-raspbian-jessie-lite.img Raspberry Pi image
#sudo raspi-config -> extend partition -> reboot
#sudo su
#apt-get update -y && apt-get upgrade -y && apt-get install git -y
#git clone https://github.com/catonrug/raspbian-nginx-cgi.git && cd raspbian-nginx-cgi && chmod +x install-nginx.sh
#time ./install-nginx.sh

#update repositories and upgrade system
apt-get update -y && apt-get upgrade -y

#install additional libraries for nginx
apt-get install php5-fpm libgd2-xpm-dev libpcrecpp0 libxpm4 -y

#install nginx web server
apt-get install nginx -y

#Install the CGI wrapper if you need to run CGI scripts on your server
apt-get install fcgiwrap -y

#Reduce the number of PHP and CGI processes to free up memory
sed -i "s/^.*process\.max = .*$/process.max = 2/" /etc/php5/fpm/php-fpm.conf

#Modify the maximum number of processes. In my case I won't have dozens of connections therefore file 
sed -i "s/^worker_processes .*;$/worker_processes 1;/" /etc/nginx/nginx.conf

#create directory for web server
mkdir -p /var/www/html

#set web server user to be owner of frontent
chown -R www-data:www-data /var/www/html

#create php sample
echo "<?php phpinfo(); ?>" > /var/www/html/index.php

#backup original configuration
cp /etc/nginx/sites-available/{default,original}

#replace active configuration
cat > /etc/nginx/sites-available/default << EOF
server {

listen 80 default_server;
listen [::]:80 default_server;

root /var/www/html;

index index.php index.html index.htm;

server_name _;

location ~ \.php\$ {
include snippets/fastcgi-php.conf;
fastcgi_pass unix:/var/run/php5-fpm.sock;
}

}
EOF

#restart nginx service
service nginx restart
service php5-fpm restart
service fcgiwrap restart

#http://raspbian-france.fr/installer-nginx-raspbian-raspberry/