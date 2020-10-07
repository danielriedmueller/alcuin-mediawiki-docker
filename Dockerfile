FROM mediawiki
RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && composer require mediawiki/semantic-media-wiki