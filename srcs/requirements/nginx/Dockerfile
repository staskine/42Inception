FROM alpine:3.20.5

RUN apk update && \
	apk add nginx openssl bash

EXPOSE 443

COPY tools/nginx-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/nginx-entrypoint.sh && \
	mkdir -p /etc/nginx/ssl

ENTRYPOINT [ "nginx-entrypoint.sh" ]
