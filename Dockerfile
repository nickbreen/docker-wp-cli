FROM wordpress:fpm

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -qy less git

# Install WP-CLI http://wp-cli.org
# Install Bash completion for WP-CLI
RUN curl -sSfLo /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  && chmod +x /usr/local/bin/wp \
  && curl -sSfLo /etc/bash_completion.d/wp-cli https://raw.githubusercontent.com/wp-cli/wp-cli/master/utils/wp-completion.bash

#RUN docker-php-ext-install zip mbstring
#
# Install PHP Composer
#RUN curl -sSf https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
#
# Install WP-CLI http://wp-cli.org
#RUN composer create-project wp-cli/wp-cli /usr/local/share/wp-cli --no-dev \
#  && ln -s /usr/local/share/wp-cli/bin/wp /usr/local/bin/wp \
#  && ls -l /usr/local/bin

RUN curl -sSfLo /usr/local/bin/docker-php-pecl-install https://raw.githubusercontent.com/helderco/docker-php/master/template/bin/docker-php-pecl-install \
  && chmod +x /usr/local/bin/docker-php-pecl-install
RUN docker-php-pecl-install oauth

COPY entrypoint.sh oauth.php /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
