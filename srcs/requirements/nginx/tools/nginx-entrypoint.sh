#!/bin/bash
set -e

if [ ! -e /etc/.firstrun ]; then
	openssl req -x509 -days 365 -newkey rsa:2048 -nodes \
		-out '/etc/nginx/ssl/cert.crt' \
		-keyout '/etc/nginx/ssl/cert.key' \
		-subj "/CN=$DOMAIN_NAME"

	cat << EOF >> /etc/nginx/http.d/default.conf

server {
	listen 443 ssl;
	listen [::]:443 ssl;
	server_name $DOMAIN_NAME;

	ssl_certificate /etc/nginx/ssl/cert.crt;
	ssl_certificate_key /etc/nginx/ssl/cert.key;
	ssl_protocols TLSv1.2 TLSv1.3;

	root /var/www/html;
	index index.php index.html index.htm;

	location / {
		try_files \$uri \$uri/ /index.php?\$args;
	}	
	

	location ~ [^/]\.php(/|\$) {
		try_files \$fastcgi_script_name =404;

        	fastcgi_pass wordpress:9000;
        	fastcgi_index index.php;
        	fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        	include /etc/nginx/fastcgi_conf;
	}
}

EOF
	touch /etc/.firstrun
fi

exec nginx -g 'daemon off;'
