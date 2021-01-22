FROM mediawiki:latest

# Install php extensions
RUN apt-get update && apt-get install -y \
        libzip-dev \
        zip \
  && docker-php-ext-install zip

# Install Xdebug
#RUN pecl install xdebug-2.9.8 && docker-php-ext-enable xdebug \
    #&& echo 'zend_extension="/usr/local/lib/php/extensions/no-debug-non-zts-20180731/xdebug.so"' >> /usr/local/etc/php/php.ini \
#    && echo 'xdebug.remote_port=9000' >> /usr/local/etc/php/php.ini \
#    && echo 'xdebug.remote_enable=1' >> /usr/local/etc/php/php.ini \
#    && echo 'xdebug.remote_connect_back=1' >> /usr/local/etc/php/php.ini

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

# Load Elastica extension extension via Git
RUN cd /var/www/html/extensions \
    && git clone --branch REL1_35 https://github.com/wikimedia/mediawiki-extensions-Elastica.git \
    && mv mediawiki-extensions-Elastica Elastica \
    && cd Elastica \
    && composer install --no-dev

# Load CirrusSearch extension via Git
RUN cd /var/www/html/extensions \
    && git clone --branch REL1_35 https://github.com/wikimedia/mediawiki-extensions-CirrusSearch.git \
    && mv mediawiki-extensions-CirrusSearch CirrusSearch

# Load ParserFunctions extension via Git
RUN cd /var/www/html/extensions \
    && git clone --branch REL1_35 https://github.com/wikimedia/mediawiki-extensions-ParserFunctions.git \
    && mv mediawiki-extensions-ParserFunctions ParserFunctions

# Load ShortDescription extension via Git
#RUN cd /var/www/html/extensions \
#    && git clone --branch REL1_35 https://github.com/wikimedia/mediawiki-extensions-ShortDescription.git \
#    && mv mediawiki-extensions-ShortDescription ShortDescription

# Load TinyMce extension via Git
#RUN cd /var/www/html/extensions \
#    && git clone --branch REL1_35 https://github.com/wikimedia/mediawiki-extensions-TinyMCE.git \
#    && mv mediawiki-extensions-TinyMCE TinyMCE

# Load SemanticDrilldown extension via Git
RUN cd /var/www/html/extensions \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/SemanticDrilldown.git

# Load Network extension fork via Git
RUN cd /var/www/html/extensions \
    && https://github.com/danielriedmueller/Network.git