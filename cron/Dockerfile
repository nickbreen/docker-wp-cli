FROM php:5.6-cli

RUN apt-get update -q && apt-get install -qy cron && apt-get clean -q && docker-php-ext-install mysqli

COPY wp.cron /etc/cron.d/wp-cron

# Start cron in the foreground, disable all logging
CMD ["cron", "-f", "-L", "0"]
