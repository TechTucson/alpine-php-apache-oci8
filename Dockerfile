FROM php:8.3.4-alpine3.19
LABEL maintainer="mario.uribe@gmail.com"
LABEL description="Alpine based image with apache2 and php8.3"

# Setup apache and php
RUN apk --no-cache --update \
    add apache2 \
    apache2-ssl \
    curl \
    php83-apache2 \
    php83-bcmath \
    php83-bz2 \
    php83-calendar \
    php83-common \
    php83-ctype \
    php83-curl \
    php83-dom \
    php83-gd \
    php83-iconv \
    php83-mbstring \
    php83-mysqli \
    php83-mysqlnd \
    php83-openssl \
    php83-pdo_mysql \
    php83-pdo_pgsql \
    php83-pdo_sqlite \
    php83-phar \
    php83-pear \
    php83-dev \
    php83-session \
    php83-xml \
    php83-soap \
    php83-pecl-xdebug \
    && mkdir /htdocs
RUN apk add gcompat
#Add OCI Instant Client
ENV LD_LIBRARY_PATH /usr/local/instantclient_21_13${LD_LIBRARY_PATH}
# Install Oracle Client and build OCI8 (Oracle Command Interface 8 - PHP extension)
RUN apk add g++ libnsl libaio make
# RUN apk add musl-dev
## Download and unarchive Instant Client v21.13

ADD oracle/21/basic.zip /tmp
ADD oracle/21/sdk.zip /tmp
ADD oracle/21/sqlplus.zip /tmp
RUN unzip -d /usr/local/ /tmp/basic.zip
RUN unzip -d /usr/local/ /tmp/sdk.zip
RUN unzip -d /usr/local/ /tmp/sqlplus.zip

## Links are required for older SDKs


RUN docker-php-ext-configure oci8 --with-oci8=instantclient,/usr/local/instantclient_21_13
RUN docker-php-ext-install oci8
RUN docker-php-ext-enable oci8
RUN echo 'extension=oci8.so' > /etc/php83/conf.d/03-oci8.ini
RUN docker-php-ext-install pdo
RUN docker-php-ext-enable pdo


#  Clean up
COPY src/index.php /var/www/localhost/htdocs/index.php
RUN cp /usr/local/lib/php/extensions/no-debug-non-zts-20230831/* /usr/lib/php83/modules/.

EXPOSE 80

ADD docker-entrypoint.sh /

#RUN apk del php83-pear php83-dev gcc musl-dev make g++ libnsl libaio 
#RUN rm -rf /tmp/*.zip /var/cache/apk/* /tmp/pear/

HEALTHCHECK CMD wget -q --no-cache --spider localhost

ENTRYPOINT ["/docker-entrypoint.sh"]