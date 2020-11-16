FROM mediawiki:latest

# Install php extensions
RUN apt-get update && apt-get install -y \
        libzip-dev \
        zip \
  && docker-php-ext-install zip

# Install Composer
RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --version=1.10.16 --install-dir=/usr/bin/ --filename=composer \
    && composer config minimum-stability dev

# Load Alcuin extension via Composer
# RUN composer clear-cache && composer require soital/alcuin:dev-master
RUN composer require soital/alcuin:dev-master

# Load DisplayTitle, PageForms and PageSchemas extension via Git
RUN cd extensions \
    && git clone https://github.com/danielriedmueller/PageForms.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/PageSchemas.git \
    && git clone -b REL1_35 https://github.com/wikimedia/mediawiki-extensions-DisplayTitle.git \
    && mv mediawiki-extensions-DisplayTitle DisplayTitle