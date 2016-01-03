FROM php:5.6-cli
# See https://github.com/docker-library/wordpress

MAINTAINER Nick Breen <nick@foobar.net.nz>

# WP-CLI requires less when showing help, ignores $PAGER!
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -q \
    && apt-get install -qy \
        jq \
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
    && docker-php-ext-install json gd mysqli \
    && docker-php-ext-enable opcache \
    && docker-php-pecl-install oauth-1.2.3 \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr

#    PHP_INI=/usr/local/etc/php/php.ini \
#    && touch $PHP_INI \
#    && pecl config-set php_ini $PHP_INI \
#    && pear config-set php_ini $PHP_INI \

ENV MYSQL_ROOT_PASSWORD="" \
    WP_LOCALE="en_NZ" \
    WP_DB_HOST="mysql" \
    WP_DB_PORT="3306" \
    WP_DB_NAME="wordpress" \
    WP_DB_USER="wordpress" \
    WP_DB_PASSWORD="wordpress" \
    WP_DB_PREFIX="wp_" \
    WP_URL="http://localhost" \
    WP_TITLE="Local Blog" \
    WP_ADMIN_USER="" \
    WP_ADMIN_PASSWORD="" \
    WP_ADMIN_EMAIL="" \
    WP_THEMES="" \
    BB_THEMES="" \
    WP_PLUGINS="" \
    BB_PLUGINS="" \
    WP_OPTIONS="" \
    WP_IMPORT="" \
    WP_EXTRA_PHP=""

COPY setup.sh oauth.php db.php /

RUN for p in /*.php; do php -l $p; done

COPY wp-cli.yml /root/.wp-cli/config.yml

VOLUME /var/www/html
WORKDIR /var/www/html

CMD ["/setup.sh"]
