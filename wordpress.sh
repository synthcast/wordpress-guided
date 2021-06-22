#!/bin/bash

password() {
printf "\n\n"
while true
do
read -p "Database user's password: " -s PASS1; printf "\n" 
read -p "Retype password: " -s PASS2; printf "\n"
if [[ $PASS1 != $PASS2 ]]; then
	printf "\nSorry, passwords do not match, please try again.\n\n"
	continue;
else
	printf "Password set successfully!\n\n"
	break;
fi
done
database
}

database() {
read -p "Database name: " DBNAME
read -p "Database user name: " UNAME
credentials
}

credentials() {
while true
do
read -p "Are these credentials correct [Y/n] " CONFIRM
case $CONFIRM in
        n|N) database; break;;
        y|Y) mysql; break;;
	*) printf "\nPlease enter Y/n\n"      
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
curl https://api.wordpress.org/secret-key/1.1/salt/ -o keys.txt
sed -i '49, 56d' wp-config.php; line=49
sed -i "${line}r keys.txt" wp-config.php; cd ..
sudo mv wordpress/ /var/www/html
cp /etc/nginx/sites-available/default .
sudo rm /etc/nginx/sites-available/default
sed -i 's/root \/var\/www\/html;/root \/var\/www\/html\/wordpress;/g' default
sed -i 's/index.nginx-debian.html;/index.nginx-debian.html index.php;/g' default
sed -i "56,61 s/$(echo a | tr 'a' '\t')//" default
sed -i "63 s/$(echo a | tr 'a' '\t')//" default
sed -i "68,70 s/$(echo a | tr 'a' '\t')//" default
sed -i '56,63 s/^#//g' default
sed -i '68,70 s/^#//g' default
sudo mv default /etc/nginx/sites-available
sudo service nginx reload
}

yes | sudo apt install nginx mysql-server php-fpm php-mysql
wget https://wordpress.org/latest.tar.gz
tar -xvf latest.tar.gz
password
