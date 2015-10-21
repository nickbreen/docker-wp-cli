FROM php:5.6-fpm
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

# Install [a] Docker PHP PECL install script
# Enable the PHP opcache extension
# Install the PECL OAuth extension
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
COPY tweaks.ini /usr/local/php/conf.d/
# Test the Configuration
RUN php -i > /dev/null

# Apparently, have to reset the entrypoint and command
ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
