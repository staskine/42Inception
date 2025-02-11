FROM alpine:3.20.5

EXPOSE 9000

RUN apk update && apk add bash curl mariadb-client icu-data-full ghostscript \
        imagemagick openssl php83 php83-fpm php83-phar php83-json php83-mysqli \
        php83-curl php83-dom php83-exif php83-fileinfo php83-pecl-igbinary \
        php83-pecl-imagick php83-intl php83-mbstring php83-openssl \
        php83-xml php83-zip php83-iconv php83-shmop php83-simplexml php83-sodium \
        php83-xmlreader php83-zlib php83-tokenizer

#RUN ln -s /usr/bin/php83 /usr/bin/php

RUN cd /usr/local/bin && \
	curl -o wp -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp

RUN which php83
RUN which php-fpm83

COPY tools/wordpress-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh

ENTRYPOINT [ "wordpress-entrypoint.sh" ]
