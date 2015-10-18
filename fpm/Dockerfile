FROM php:5.6-fpm
# See https://github.com/docker-library/wordpress

MAINTAINER Nick Breen <nick@foobar.net.nz>

# WP-CLI requires less when showing help, ignores $PAGER!
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -q \
    && apt-get install -qy \
        less \
        libpng12-dev \
        libjpeg-dev \
    && apt-get clean

# Install WP-CLI http://wp-cli.org
# Install Bash completion for WP-CLI
RUN PHAR=/usr/local/lib/php/wp-cli.phar &&\
    curl -sSfLo $PHAR https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar &&\
    chmod +x $PHAR &&\
    ln -s $PHAR /usr/local/bin/wp &&\
    curl -sSfLo /etc/bash_completion.d/wp-cli https://raw.githubusercontent.com/wp-cli/wp-cli/master/utils/wp-completion.bash

# Install [a] Docker PHP PECL install script
# Enable the PHP opcache extension
# Install the PECL OAuth extension
RUN PECL=/usr/local/bin/docker-php-pecl-install \
    && curl -sSfLo $PECL https://raw.githubusercontent.com/helderco/docker-php/master/template/bin/docker-php-pecl-install \
    && chmod +x $PECL \
    && docker-php-ext-enable opcache \
    && docker-php-pecl-install oauth \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install gd \
    && docker-php-ext-install mysqli

ENV WP_LOCALE="en_NZ" \
    WP_DB_HOST="db" \
    WP_DB_PORT="3306" \
    WP_DB_NAME="wordpress" \
    WP_DB_USER="wordpress" \
    WP_DB_PASSWORD="wordpress" \
    WP_DB_PREFIX="wp_" \
    WP_URL="http://example.com" \
    WP_TITLE="Example Blog" \
    WP_ADMIN_USER="admin" \
    WP_ADMIN_PASSWORD="**change me**" \
    WP_ADMIN_EMAIL="admin@example.com" \
    WP_THEMES="" \
    BB_THEMES="" \
    WP_PLUGINS="" \
    BB_PLUGINS="" \
    WP_OPTIONS=""

#    WP_IMPORT "" \

# Install New Relic support
RUN echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' | tee /etc/apt/sources.list.d/newrelic.list \
    && curl -sSfL https://download.newrelic.com/548C16BF.gpg | apt-key add - \
    && apt-get update -q \
    && apt-get install -qy newrelic-php5 \
    && apt-get clean

ENV NR_INSTALL_SILENT=true \
    NR_INSTALL_KEY="" \
    NR_APP_NAME="${WP_URL}"

COPY tweaks.ini /usr/local/php/conf.d/
RUN php -i > /dev/null

COPY entrypoint.sh oauth.php db.php /

# Apparently, have to reset the entrypoint and command
ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
