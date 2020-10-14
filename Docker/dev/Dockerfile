FROM mediawiki:latest

# Install php extensions
RUN apt-get update && apt-get install -y \
        libzip-dev \
        zip \
  && docker-php-ext-install zip

RUN pecl install xdebug-2.9.8 && docker-php-ext-enable xdebug
RUN echo 'zend_extension="/usr/local/lib/php/extensions/no-debug-non-zts-20151012/xdebug.so"' >> /usr/local/etc/php/php.ini
RUN echo 'xdebug.remote_port=9000' >> /usr/local/etc/php/php.ini
RUN echo 'xdebug.remote_enable=1' >> /usr/local/etc/php/php.ini
RUN echo 'xdebug.remote_connect_back=1' >> /usr/local/etc/php/php.ini

# Load Alcuin extension via Composer
RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && composer config minimum-stability dev \
    && composer require soital/alcuin:dev-master

# Load PageSchemas extension via Git
RUN cd extensions && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/PageSchemas.git