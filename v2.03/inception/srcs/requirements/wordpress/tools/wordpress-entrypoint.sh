#!/bin/bash
set -e

echo "memory_limit = 512M" >> /etc/php83/php.ini

echo "Starting wordpress setup!"

# I am making sure php was installed correctly
php-fpm83 -v || { echo "PHP-FPM is not installed or not working"; exit 1; }

# Waiting for mariaDB to set up
until mariadb-admin ping --protocol=tcp --host=mariadb -u"$MYSQL_USER" --password="$MYSQL_PASSWORD" --wait >/dev/null 2>&1; do                                    
	sleep 2                                                                                                                                                       
done

cd /var/www/html

if [ ! -f wp-config.php ]; then
   	echo "Wordpress not installed. Installing now."
	
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp
	    
	wp core download --allow-root
        wp config create --allow-root --dbhost=mariadb --dbuser="$MYSQL_USER" \
            --dbpass="$MYSQL_PASSWORD" --dbname="$MYSQL_DATABASE"
        wp core install --allow-root  --skip-email  --url="$DOMAIN_NAME"  --title="Inception" \
            --admin_user="$WORDPRESS_ADMIN_USER"  --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
            --admin_email="$WORDPRESS_ADMIN_EMAIL"

        if ! wp user get "$WORDPRESS_USER" --allow-root > /dev/null 2>&1; then
            wp user create "$WORDPRESS_USER" "$WORDPRESS_EMAIL" --role=author --user_pass="$WORDPRESS_PASSWORD" --allow-root
        fi

	echo "Wordpress installation complete."
else
	echo "WordPress was already installed."
fi

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html/wp-content

echo "Starting up PHP-FPM"
exec php-fpm83 -F
