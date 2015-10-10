FROM php:5.6-fpm
# See https://github.com/docker-library/wordpress

MAINTAINER Nick Breen <nick@foobar.net.nz>

# WP-CLI requires less when showing help, ignores $PAGER!
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
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

COPY entrypoint.sh oauth.php /

ENV WP_LOCALE "en_NZ"
ENV WP_DB_HOST "**automatically uses \$MYSQL_PORT_3306_TCP_ADDR**"
ENV WP_DB_PORT "**automatically uses \$MYSQL_PORT_3306_TCP_PORT**"
ENV WP_DB_NAME "**automatically uses \$MYSQL_DATABASE**"
ENV WP_DB_USER "**automatically uses \$MYSQL_USER**"
ENV WP_DB_PASSWORD "**automatically uses \$MYSQL_PASSWORD**"
ENV WP_DB_PREFIX "wp_"

ENV WP_URL "http://example.com"
ENV WP_TITLE "Example Blog"
ENV WP_ADMIN_USER "admin"
ENV WP_ADMIN_PASSWORD "**change me**"
ENV WP_ADMIN_EMAIL "admin@example.com"

ENV WP_THEMES ""
ENV BB_THEMES ""
ENV WP_PLUGINS ""
ENV BB_PLUGINS ""

ENV WP_IMPORT ""
ENV WP_OPTIONS ""

# Apparently, have to reset the entrypoint and command
ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]