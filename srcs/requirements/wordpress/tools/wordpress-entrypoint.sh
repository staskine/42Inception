#!/bin/bash
set -e

echo "Starting wordpress setup!"

# I am making sure php was installed correctly
php-fpm83 -v || { echo "PHP-FPM is not installed or not working"; exit 1; }

sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /etc/php83/php-fpm.d/www.conf

# Waiting for mariaDB to set up
until mariadb-admin ping --protocol=tcp --host=mariadb -u"$MYSQL_USER" --password="$MYSQL_PASSWORD" --wait >/dev/null 2>&1; do                                    
	sleep 2                                                                                                                                                       
done

cd /var/www/html

if [ ! -f wp-config.php ]; then
   	echo "Wordpress not installed. Installing now."
    
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
fi

echo "Starting up PHP-FPM"
exec php-fpm83 -F
