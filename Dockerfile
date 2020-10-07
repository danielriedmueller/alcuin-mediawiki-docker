FROM mediawiki

RUN apt-get update && apt-get install -y \
        libzip-dev \
        zip \
  && docker-php-ext-install zip

RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && composer require mediawiki/semantic-media-wiki \
    && composer require mediawiki/chameleon-skin