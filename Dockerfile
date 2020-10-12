FROM mediawiki

# Install php extensions
RUN apt-get update && apt-get install -y \
        libzip-dev \
        zip \
  && docker-php-ext-install zip

# Load Alcuin extension via Composer
RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && composer require soital/alcuin:dev-master

# Load PageSchemas extension via Git
RUN cd extensions && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/PageSchemas.git