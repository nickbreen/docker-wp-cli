FROM php:5.6-apache
# Also see https://github.com/docker-library/wordpress

MAINTAINER Nick Breen <nick@foobar.net.nz>

# Install New Relic support
RUN echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' | tee /etc/apt/sources.list.d/newrelic.list \
    && curl -sSfL https://download.newrelic.com/548C16BF.gpg | apt-key add - \
    && apt-get update -q \
    && apt-get install -qy \
        libjpeg-dev \
        libpng12-dev \
        newrelic-php5 \
    && apt-get clean

# Enable the PHP opcache extension
RUN docker-php-ext-enable opcache \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install gd \
    && docker-php-ext-install mysqli

ENV NR_INSTALL_SILENT=true \
    NR_INSTALL_KEY="" \
    NR_APP_NAME="${WP_URL}"

# Add entrypoint, to install newrelic
COPY entrypoint.sh /

# Configure mod_rewrite, mod_cache, mod_php
# Test the configuration
COPY wp.conf /etc/apache2/conf-available/
RUN a2enmod rewrite cache_disk expires \
    && a2enconf wp \
    && apache2ctl -t

# Apparently, have to reset the entrypoint and command
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
