#!/bin/sh

# Log the environment variables to check if they are set correctly
echo "DOMAIN_NAME: $DOMAIN_NAME"
echo "SSL_CERTIFICATE: $SSL_CERTIFICATE"
echo "KEY_PATH: $KEY_PATH"

if [ ! -f "$SSL_CERTIFICATE" ] || [ ! -f "$KEY_PATH" ]; then
    echo "SSL certificate or key not found. Generating new ones..."

    # Generate SSL certificate and key
    openssl req -newkey rsa:2048 -x509 -sha256 -days 365 -nodes \
        -out "$SSL_CERTIFICATE" \
        -keyout "$KEY_PATH" \
        -subj "/CN=${DOMAIN_NAME:-localhost}"

    echo "SSL certificate and key generated."
fi

# Replace placeholders in nginx.conf with environment variables
sed -i "s|DOMAIN_NAME|$DOMAIN_NAME|g" /etc/nginx/nginx.conf
sed -i "s|SSL_CERTIFICATE|$SSL_CERTIFICATE|g" /etc/nginx/nginx.conf
sed -i "s|KEY_PATH|$KEY_PATH|g" /etc/nginx/nginx.conf

# Log the updated nginx.conf
echo "nginx.conf after substitution:"
cat /etc/nginx/nginx.conf


# Start Nginx with the custom configuration
exec nginx -c /etc/nginx/nginx.conf -g "daemon off;