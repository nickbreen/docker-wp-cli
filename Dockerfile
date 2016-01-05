FROM nickbreen/cron

# Extending 'cron' is a little odd, but it's useful for setting up a container
# for cron jobs that use WP-CLI.

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

ENTRYPOINT [ "wp", "--allow-root" ]
CMD [ "help" ]
