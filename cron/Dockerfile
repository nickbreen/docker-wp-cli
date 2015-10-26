FROM php:5.6-cli

RUN apt-get update -q && apt-get install -qy cron rsyslog supervisor && apt-get clean -q

RUN docker-php-ext-install mysqli

COPY wp.cron /etc/cron.d/wp-cron
COPY supervisord.conf /etc/supervisor/conf.d/

CMD ["supervisord"]

