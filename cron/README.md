A lightweight cron container.

# Configuration

Configure the cron container using environment variables.

|Variable|Default|Purpose|Example|
|--------|-------|-------|-------|
|CRON_OWNER   |```root```|The user whose crontab to edit.|```www-data```|
|CRON_TAB     ||[crontab] job specifications.|```* * * * * command```|
|CRON_ENV_FILE||A file to perist environment variables to, so they can be made available to _command_.|```/var/cron.env```

Note that the CRON_TAB value is piped directly into ```crontab``` and can also specify other cron options; e.g. ```SHELL=/bin/bash```.

[crontab]: https://www.debian-administration.org/article/56/Command_scheduling_with_cron

## Example: ```docker-compose.yml```

    # docker-compose.yml    
    cron:
      build: .
      links:
        - mysql:mysql
      volumes_from:
        - apache:apache
      environment:
        CRON_ENV_FILE: /var/env.cron
        CRON_OWNER: www-data
        CRON_TAB: |
          # Every hour" clean mod_cache_disk's cache.
          0 * * * * htcacheclean -n -p/var/cache/apache2/mod_cache_disk
          # At 4am: dump a MySQL DB, compress it, and upload it to S3.
          0 4 * * * . /var/env.cron; mysqldump -h$$MYSQL_PORT_3306_TCP_ADDRT_3306 -P$$MYSQL_PORT_3306_TCP_PORT -u$$MYSQL_ENV_MYSQL_USER -p$$MYSQL_ENV_MYSQL_PASSWORD $$MYSQL_ENV_MYSQL_DATABASE | gzip | s3cmd put - s3://bucket/backup-$$MYSQL_ENV_MYSQL_DATABASE.sql

Note the escaped (```$$```) variables in ```CRON_TAB``` as ```docker-compose``` will try to evaluate variables.

Note this image does not include Apache, s3cmd, or MySQL so the ```mysqldump```, ```htcacheclean``` and ```s3cmd``` commands are not actually available! One would need to extend this image thus:

    # Dockerfile
    FROM nickbreen/cron

    RUN DEBIAN_FRONTEND=noninteractive && \
      apt-get -q update && \
      apt-get -qy install mysql-client apache2-utils s3cmd && \
      apt-get -q clean

    # And so on ... configure s3cmd etc.

# Logging

cron jobs are not logged _per-se_. Instead their output is emailed to the owner of the crontab.

In this image all this mail just spools into ```/var/spool/mail/```.

Locally it's easy enough to host-mount a volume at ```/var/spool/mail/``` and monitor the files. Remotely this can be effected with:

    cron:
      build: .
      environment:
        CRON_TAB: |
          # Every minute: say "Hello World".
          * * * * * echo Hello World!
      volumes:
        - /var/mail

    mail:
      image: debian:stable
      command: bash -c 'while ! tail -F /var/mail/*; do sleep 1; done'
      volumes_from:
        - cron

This container will simply log out the mail spool (somewhat verbosely).
