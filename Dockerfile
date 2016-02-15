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

RUN mkdir /usr/local/share/php && cd /usr/local/share/php &&\
  curl -sSfLJO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar &&\
  php wp-cli.phar --allow-root cli version &&\
  chmod +x wp-cli.phar &&\
  ln -s /usr/local/share/php/wp-cli.phar /usr/local/bin/wp &&\
  wp --allow-root cli version &&\
  curl -sSfLo /etc/bash_completion.d/wp-cli https://raw.githubusercontent.com/wp-cli/wp-cli/master/utils/wp-completion.bash &&\
  curl -sS https://getcomposer.org/installer | php &&\
  php composer.phar -V &&\
  chmod +x composer.phar &&\
  ln -s /usr/local/share/php/composer.phar /usr/local/bin/composer &&\
  composer -V
