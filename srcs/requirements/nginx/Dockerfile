FROM alpine:3.20.5

RUN apk update && \
	apk add nginx openssl

EXPOSE 443

COPY tools/nginx-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/nginx-entrypoint.sh

RUN mkdir -p /run/nginx /etc/nginx/ssl

RUN openssl req -newkey rsa:2048 -x509 -sha256 -days 365 -nodes \
    -out /etc/nginx/ssl/certificate.crt \
    -keyout /etc/nginx/ssl/certificate.key \
    -subj "/CN=${DOMAIN_NAME:-localhost}"

RUN adduser -D -H -s /sbin/nologin -g www-data -G www-data www-data

COPY conf/nginx.conf /etc/nginx/nginx.conf
RUN chmod 644 /etc/nginx/nginx.conf

ENTRYPOINT [ "nginx-entrypoint.sh" ]
