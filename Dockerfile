FROM nickbreen/cron:v1.0.0

MAINTAINER Nick Breen <nick@foobar.net.nz>

RUN apt-get update -qqy && \
  DEBIAN_FRONTEND=noninteractive apt-get install -qqy \
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
  && apt-get clean -qqy

ENV PHP_DIR=/usr/local/share/php WP_CLI_VERSION=0.23.0 COMPOSER_VERSION=1.0.0-beta1

RUN mkdir -p $PHP_DIR

RUN curl -sSfJLo $PHP_DIR/composer.phar https://getcomposer.org/download/$COMPOSER_VERSION/composer.phar | php &&\
  php $PHP_DIR/composer.phar -V &&\
  chmod +x $PHP_DIR/composer.phar &&\
  ln -s $PHP_DIR/composer.phar /usr/local/bin/composer &&\
  composer -V

RUN curl -sSfLo /etc/bash_completion.d/wp-cli https://raw.githubusercontent.com/wp-cli/wp-cli/v$WP_CLI_VERSION/utils/wp-completion.bash &&\
  curl -sSfJLo $PHP_DIR/wp-cli.phar https://github.com/wp-cli/wp-cli/releases/download/v$WP_CLI_VERSION/wp-cli-$WP_CLI_VERSION.phar &&\
  php $PHP_DIR/wp-cli.phar --allow-root cli version &&\
  chmod +x $PHP_DIR/wp-cli.phar &&\
  ln -s $PHP_DIR/wp-cli.phar /usr/local/bin/wp &&\
  wp --allow-root cli version
