FROM nickbreen/wp-cli:wp-api

MAINTAINER Nick Breen <nick@foobar.net.nz>

USER root

RUN export DEBIAN_FRONTEND=noninteractive &&\
    apt-get update -q && apt-get install -qy zip && apt-get clean

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

COPY setup.sh oauth.php /

RUN php -l /oauth.php && bash -n /setup.sh

RUN mkdir -p /var/www/html/wp-content/uploads && \
  chown -R wp:wp /var/www/html && \
  chown wp:www-data /var/www/html/wp-content/uploads && \
  chmod g+w /var/www/html/wp-content/uploads

VOLUME /var/www/html /var/www/html/wp-content/uploads
WORKDIR /var/www/html

USER wp

CMD ["/setup.sh"]
