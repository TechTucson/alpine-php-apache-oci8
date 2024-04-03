FROM php:8.3.4-apache

RUN apt-get update && apt-get install -qqy git unzip libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libaio1 wget && apt-get clean autoclean && apt-get autoremove --yes &&  rm -rf /var/lib/{apt,dpkg,cache,log}/ 
#composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# ORACLE oci 
RUN mkdir /opt/oracle \
    && cd /opt/oracle     
    
ADD oracle/21/instantclient-basic-linux.x64-21.13.0.0.0dbru.zip /opt/oracle
ADD oracle/21/instantclient-sdk-linux.x64-21.13.0.0.0dbru.zip /opt/oracle
ADD oracle/21/instantclient-sqlplus-linux.x64-21.13.0.0.0dbru.zip /opt/oracle

# Install Oracle Instantclient
RUN unzip /opt/oracle/instantclient-basic-linux.x64-21.13.0.0.0dbru.zip -d /opt/oracle
RUN unzip /opt/oracle/instantclient-sdk-linux.x64-21.13.0.0.0dbru.zip -d /opt/oracle
RUN unzip /opt/oracle/instantclient-sqlplus-linux.x64-21.13.0.0.0dbru.zip -d /opt/oracle
#RUN ln -s /opt/oracle/instantclient_21_13/libclntsh.so.21.1 /opt/oracle/instantclient_21_13/libclntsh.so
#RUN ln -s /opt/oracle/instantclient_21_13/libclntshcore.so.21.1 /opt/oracle/instantclient_21_13/libclntshcore.so
#RUN ln -s /opt/oracle/instantclient_21_13/libocci.so.21.1 /opt/oracle/instantclient_21_13/libocci.so
RUN rm -rf /opt/oracle/*.zip
RUN apt-get remove wget -y
RUN apt remove unzip -y
    
ENV LD_LIBRARY_PATH  /opt/oracle/instantclient_21_13:${LD_LIBRARY_PATH}
    
# Install Oracle extensions
RUN echo 'instantclient,/opt/oracle/instantclient_21_13/' | pecl install oci8 \ 
      && docker-php-ext-enable \
               oci8 \ 
       && docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/opt/oracle/instantclient_21_13,21.1 \
       && docker-php-ext-install \
               pdo_oci 
			  
# Install LDAP

RUN apt-get update \
    && apt-get install libldap2-dev -y \
    && docker-php-ext-install ldap \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install ldap

#Install SOAP
RUN apt-get update && \
    apt-get install -y libxml2-dev

RUN docker-php-ext-install soap


WORKDIR /var/www/html

COPY apache/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY apache/charset.conf /etc/apache2/conf-available/charset.conf
COPY php/timezone.ini /usr/local/etc/php/conf.d/timezone.ini
COPY src/index.php /var/www/html/public/index.php
COPY php/vars-pro.ini /usr/local/etc/php/conf.d/vars.ini

RUN cp -f "/usr/local/etc/php/php.ini-production" /usr/local/etc/php/php.ini
RUN apt-get clean autoclean && apt-get autoremove --yes

EXPOSE 80