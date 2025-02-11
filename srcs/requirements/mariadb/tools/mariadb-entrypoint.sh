#!/bin/bash

echo "I am executing mariaDB entrypoint script"

if [ ! -e /var/lib/mysql/.firstmount ]; then
	echo "I am creating a new container for mariadb"
	mysql_install_db --datadir=/var/lib/mysql --skip-test-db --user=mysql 
	mysqld --user=mysql --bootstrap << EOF


FLUSH PRIVILEGES;
CREATE DATABASE $MYSQL_DATABASE;
CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
GRANT ALL PRIVILEGES on *.* to 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
FLUSH PRIVILEGES;
EOF
	touch /var/lib/mysql/.firstmount
fi

exec mysqld --user=mysql
