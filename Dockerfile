FROM wordpress:fpm

# WP-CLI requires less when showing help, ignores $PAGER!
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -qy less

# Install WP-CLI http://wp-cli.org
# Install Bash completion for WP-CLI
RUN PHAR=/usr/local/lib/php/wp-cli.phar &&\
    curl -sSfLo $PHAR https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar &&\
    chmod +x $PHAR &&\
    ln -s $PHAR /usr/local/bin/wp &&\
    curl -sSfLo /etc/bash_completion.d/wp-cli https://raw.githubusercontent.com/wp-cli/wp-cli/master/utils/wp-completion.bash

RUN PECL=/usr/local/bin/docker-php-pecl-install &&\
    curl -sSfLo $PECL https://raw.githubusercontent.com/helderco/docker-php/master/template/bin/docker-php-pecl-install &&\
    chmod +x $PECL &&\
    docker-php-pecl-install oauth

COPY entrypoint.sh oauth.php /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
