
**Important**: the apache, fpm, cron, and wp-api tags have moved to their own projects.

- apache and fpm -> [nickbreen/wp-php](nickbreen/wp-php)
- cron -> [nickbreen/cron](nickbreen/cron)
- wp-api -> [nickbreen/wp-api](nickbreen/wp-api)

# What are WordPress and WP-CLI?

[WordPress] is a free and open source blogging tool and a content management system (CMS) based on PHP and MySQL, which runs on a web hosting service. Features include a plugin architecture and a template system. WordPress is used by more than 22.0% of the top 10 million websites as of August 2013. WordPress is the most popular blogging system in use on the Web, at more than 60 million websites. The most popular languages used are English, Spanish and Bahasa Indonesia.

[WP-CLI] is a command line tool to administer a WordPress installation.

[WordPress]: https://wordpress.org "Blog Tool, Publishing Platform, and CMS"
[WP-CLI]: http://wp-cli.org "A command line interface for WordPress"

# Usage

This image is based on a cron service that runs continuously.

See [docker-compose.yml](./docker-compose.yml) for a trivial example.

# Advanced Usage

Any list of WP-CLI commands can be executed with a little shell and environment trickery.

See [docker-compose.yml](./docker-compose.yml) for an advanced examples ```wpz``` and ```wpx```.

# Cron

You should disable WP's cron function and specify a cron job to invoke WP's cron jobs.

    wp core config ... --extra-php <<-PHP    
      define('DISABLE_WP_CRON', true);
    PHP
    ...
    wp cron test

And in ```docker-compose.yml```:

    wp-cron:
      build: .
      environment:
        CRON_TAB: |-
          # Execute WP's cron jobs
          * * * * * wp cron event list --format=csv  --fields=hook,next_run_relative | awk -F ',' '$2 == "now" {print $1}' | xargs -l1 wp cron event run
          # Backup WP
          0 3 * * * wp db export 
          # Update WP
          0 4 * * * wp core update; wp core update-db; wp theme update --all; wp plugin update --all
