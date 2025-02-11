#!/bin/bash
set -e
cd /var/www/html

which /usr/bin/php83 || { echo "PHP was not found"; exit 1; }
which /usr/sbin/php-fpm83 || { echo "PHP-FPM was not found"; exit 1; }

export PATH=$PATH:/usr/bin:/usr/sbin

if [ ! -e /etc/.firstrun ]; then
    sed -i 's/user = nobody/group = nobody/listen = 127.0.0.1:9000/listen = 9000/g' /etc/php83/php-fpm.d/www.conf
    touch /etc/.firstrun
fi

if [ ! -e .firstmount ]; then
    mariadb-admin ping --protocol=tcp --host=mariadb -u "$MYSQL_USER" --password="$MYSQL_PASSWORD" --wait >/dev/null 2>/dev/null

    if [ ! -f wp-config.php ]; then
        echo "I am Installing WordPress..."

        wp core download --allow-root || true
        wp config create --allow-root --dbhost=mariadb --dbuser="$MYSQL_USER" \
            --dbpass="$MYSQL_PASSWORD" --dbname="$MYSQL_DATABASE"
        wp core install --allow-root  --skip-email  --url="$DOMAIN_NAME"  --title="Inception" \
            --admin_user="$WORDPRESS_ADMIN_USER"  --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
            --admin_email="$WORDPRESS_ADMIN_EMAIL"

        if ! wp user get "$WORDPRESS_USER" --allow-root > /dev/null 2>&1; then
            wp user create "$WORDPRESS_USER" "$WORDPRESS_EMAIL" --role=author --user_pass="$WORDPRESS_PASSWORD" --allow-root
        fi
    else
        echo "WordPress was already installed."
    fi

    chown -R www-data:www-data /var/www/html
    chmod o+w -R /var/www/html/wp-content
    touch .firstmount
fi

echo "Starting up PHP-FPM"
exec /usr/sbin/php-fpm83 -F

