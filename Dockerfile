FROM nickbreen/wp-php:v1.3.3

MAINTAINER Nick Breen <nick@foobar.net.nz>

RUN apt-get update -y && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
    bash-completion \
    curl \
    git \
    jq \
    less \
    mysql-client \
    zip \
  && apt-get clean -y

ARG PHP_DIR=/usr/local/share/php
ARG WP_CLI_VERSION=0.24.1
ARG COMPOSER_VERSION=1.2.0

RUN useradd -m -s /bin/bash wp

RUN mkdir -p $PHP_DIR

RUN curl -sSfJLo $PHP_DIR/composer.phar https://getcomposer.org/download/$COMPOSER_VERSION/composer.phar &&\
  chmod +x $PHP_DIR/composer.phar &&\
  ln -s $PHP_DIR/composer.phar /usr/local/bin/composer &&\
  chpst -u wp composer -V

RUN curl -sSfLo /etc/bash_completion.d/wp-cli https://raw.githubusercontent.com/wp-cli/wp-cli/v$WP_CLI_VERSION/utils/wp-completion.bash &&\
  curl -sSfJLo $PHP_DIR/wp-cli.phar https://github.com/wp-cli/wp-cli/releases/download/v$WP_CLI_VERSION/wp-cli-$WP_CLI_VERSION.phar &&\
  chmod +x $PHP_DIR/wp-cli.phar &&\
  ln -s $PHP_DIR/wp-cli.phar /usr/local/bin/wp &&\
  chpst -u wp wp cli version

WORKDIR /home/wp
