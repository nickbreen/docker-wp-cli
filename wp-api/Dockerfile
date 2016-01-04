FROM debian:jessie

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

#RUN REPO=WP-API/client-cli set -x &&\
RUN REPO=nickbreen/client-cli set -x &&\
  cd /usr/local/share/php &&\
  git clone https://github.com/${REPO} &&\
  cd ${REPO#*/} &&\
  composer install

RUN echo "alias wp-api='wp --require=/usr/local/share/php/client-cli/client.php api'" >> /etc/skel/.bash_aliases

RUN useradd -m wp && chown -R wp:wp /home/wp

ENV WP_URL http://localhost

USER wp
WORKDIR /home/wp
