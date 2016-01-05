FROM nickbreen/cron

MAINTAINER Nick Breen <nick@foobar.net.nz>

RUN DEBIAN_FRONTEND=noninteractive &&\
  apt-get update && apt-get install -y \
    bash-completion \
    curl \
    git \
    jq \
    less \
    mysql-client \
    php5-cli \
    php5-curl \
    php5-json \
    php5-mysql \
    php5-oauth \
    zip \
  && apt-get clean

RUN mkdir /usr/local/share/php && cd /usr/local/share/php &&\
  curl -sSfLJO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar &&\
  php wp-cli.phar --info --allow-root &&\
  chmod +x wp-cli.phar &&\
  ln -s /usr/local/share/php/wp-cli.phar /usr/local/bin/wp &&\
  wp --info --allow-root &&\
  curl -sSfLo /etc/bash_completion.d/wp-cli https://raw.githubusercontent.com/wp-cli/wp-cli/master/utils/wp-completion.bash &&\
  curl -sS https://getcomposer.org/installer | php &&\
  php composer.phar -V &&\
  chmod +x composer.phar &&\
  ln -s /usr/local/share/php/composer.phar /usr/local/bin/composer &&\
  composer -V

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

RUN useradd -m wp && chown -R wp:wp /home/wp

COPY setup.sh oauth.php /

RUN php -l /oauth.php && bash -n /setup.sh

RUN mkdir -p /var/www/html/wp-content/uploads && \
  chown -R wp:wp /var/www/html && \
  chown wp:www-data /var/www/html/wp-content/uploads && \
  chmod g+w /var/www/html/wp-content/uploads

VOLUME /var/www/html /var/www/html/wp-content/uploads
WORKDIR /var/www/html

USER wp
