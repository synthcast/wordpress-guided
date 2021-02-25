#!/bin/bash

credentials () {
printf "\n\n"
read -p "Enter mysql database name: " DBNAME
read -p "Enter mysql database user name: " UNAME
read -p "Enter mysql database user password: " PASS

printf "\n\n"
printf "db_name: $DBNAME\ndb_user: $UNAME\ndb_password: $PASS\n"
printf "\n\n"
while true
do
read -p "Are these credentials correct [Y/n] " CONFIRM
case $CONFIRM in
        n|N) credentials; break;;
        y|Y) mysql; break;;
        *) echo 'Please enter y/n'      
esac
done
}

mysql() {
sudo mysql_secure_installation
sudo mysql <<EOF
create user '$UNAME'@'localhost' identified by '$PASS';
create database $DBNAME character set utf8 collate utf8_unicode_ci;
grant all on $DBNAME.* to '$UNAME'@'localhost';
flush privileges;
EOF
setup
}

setup() {
cd wordpress/
mv wp-config-sample.php wp-config.php;
sed -i "s|database_name_here|${DBNAME}|g" wp-config.php
sed -i "s|username_here|${UNAME}|g" wp-config.php
sed -i "s|password_here|${PASS}|g" wp-config.php
printf "You'll need to copy these randomly generated keys and paste them into the config file. You can copy the keys from https://api.wordpress.org/secret-key/1.1/salt/ if they didn't display in the terminal correctly\n\n"
curl https://api.wordpress.org/secret-key/1.1/salt/; printf "\n\n"
read -p "Press [Enter] when you are ready to proceed "
vim +49 wp-config.php -c 'normal zt'; cd ..
sudo mv wordpress/ /var/www/html
cp /etc/nginx/sites-available/default .
sudo rm /etc/nginx/sites-available/default
sed -i 's/root \/var\/www\/html;/root \/var\/www\/html\/wordpress;/g' default
sed -i 's/index index.html index.htm index.nginx-debian.html;/index index.html index.htm index.nginx-debian.html index.php;/g' default
sed -i.bak "56,61 s/$(echo a | tr 'a' '\t')//" default
sed -i.bak "63 s/$(echo a | tr 'a' '\t')//" default
sed -i.bak "68,70 s/$(echo a | tr 'a' '\t')//" default
sed -i '56,63 s/^#//g' default
sed -i '68,70 s/^#//g' default
sudo mv default /etc/nginx/sites-available
sudo service nginx reload
}

yes | sudo apt install nginx mysql-server php-fpm php-mysql
wget https://wordpress.org/latest.tar.gz
tar -xvf latest.tar.gz
credentials

