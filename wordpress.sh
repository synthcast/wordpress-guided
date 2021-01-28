#! /usr/bin/bash

yes | apt install nginx mysql-server php-fpm php-mysql

wget https://wordpress.org/latest.tar.gz
echo 'wordpress downloaded'; echo 'unzipping in 3s...'
sleep 3
tar -xvf latest.tar.gz
mv wordpress/ /var/www/html
cd /var/www/html/wordpress
cp wp-config-sample.php wp-config.php
echo 'files moved'; echo 'proceeding with mysql installation in 5s (you will need to enter the root password)'
sleep 5

mysql_secure_installation << 'EOF'
n
y
y
y
y
EOF

sleep 1
echo 'proceeding with mysql...'
sleep 2
mysql << 'EOF'
create user 'admin'@'localhost' identified by 'password'; 
EOF
echo 'user created'
sleep 1
mysql << 'EOF'
create database wordpress character set utf8 collate utf8_unicode_ci;
EOF
echo 'database created'
sleep 1
mysql << 'EOF'
grant all on wordpress.* to 'admin'@'localhost';
EOF
echo 'privileges granted'
sleep 1
mysql << 'EOF'
flush privileges;
EOF
echo 'privileges flushed'
sleep 1

echo 'you will need to enter the credential bellow into the wordpress config file'
echo ''
echo 'db_name: wordpress'; echo 'db_user: admin'; echo 'db_passwd: password' 
sleep 3
echo ''
echo 'you will also need to copy these radnomly generated keys form https://api.wordpress.org/secret-key/1.1/salt/
and insert them aswell'
echo ''

read -p "When you are ready hit 'y' to proceed with the guided setup or 'n' to exit: " PROMPT
case "$PROMPT" in
	[y/Y] | [y/Y][e/E][s/S])
		echo 'opening wp-config.php...'
		sleep 2
		vim wp-config.php
		echo 'the last thing you will need to do is to:'
	       	echo '1.set the root of the nginx conf file to /var/www/html/wordpress'
	        echo '2.add index.php to the list bellow'
	        echo '3.and allow the passing of PHP scripts to FastCGI server'
		read -p "When you are ready, hit 'y' to proceed or 'n' to exit: " PROMPT2
                case "$PROMPT2" in
                	[y/Y] | [y/Y][e/E][s/S])
			        echo 'opening default.conf'
			        sleep 2
			        vim /etc/nginx/sites-available/default
			        echo 'setup complete, reloading services...'
				wait 2
			        service nginx reload
			        echo 'services reloaded'
				;;
			[n/N] | [n/N][o/O])
                                echo 'exiting..'
				;;
			
		esac		
	[n/N] | [n/N][o/O]	
        echo 'exiting..'
	;;
	*)
esac
