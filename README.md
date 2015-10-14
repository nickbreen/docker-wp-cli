# Supported tags and respective `Dockerfile` links

- [`apache` (*apache/Dockerfile*)](https://github.com/nickbreen/docker-wp-cli/blob/master/apache/Dockerfile)
- [`fpm` (*fpm/Dockerfile*)](https://github.com/nickbreen/docker-wp-cli/blob/master/fpm/Dockerfile)

# What is WordPress?

WordPress is a free and open source blogging tool and a content management system (CMS) based on PHP and MySQL, which runs on a web hosting service. Features include a plugin architecture and a template system. WordPress is used by more than 22.0% of the top 10 million websites as of August 2013. WordPress is the most popular blogging system in use on the Web, at more than 60 million websites. The most popular languages used are English, Spanish and Bahasa Indonesia.

> [wikipedia.org/wiki/WordPress](https://en.wikipedia.org/wiki/WordPress)

# This Image

[WP-CLI] installed, configured, and managed WordPress site.

Themes, plugins, and options can be specified as environment variables for configuration on start up.  The DB will be created if required and requires ```MYSQL_ENV_MYSQL_ROOT_PASSWORD``` be set.

Use ```:apache``` or ```:fpm``` as required.

See docker-compose.yml for an example of configuration.

[WP-CLI] http://wp-cli.org "A command line interface for WordPress"

# Usage

Everything is specified using environment variables. See the example above.

## Download 
Uses ```wp core download```.

The latest WordPress version will be downloaded and extracted.

## Configuration 
Uses ``` wp core config```.

The database configuration can be specified explicitly with:
- ```WP_DB_HOST```
- ```WP_DB_PORT```
- ```WP_DB_NAME```
- ```WP_DB_USER```
- ```WP_DB_PASSWORD```
- ```WP_DB_PREFIX```

If any are omitted then values are inferred from the linked ```:mysql``` container, otherwise sensible defaults are used.

Variable             | Value inferred from            | Default
-------------------- | ------------------------------ | ---------
```WP_DB_NAME```     | ```MYSQL_ENV_MYSQL_DATABASE``` | wordpress
```WP_DB_USER```     | ```MYSQL_ENV_MYSQL_USER```     | wordpress
```WP_DB_PASSWORD``` | ```MYSQL_ENV_MYSQL_PASSWORD``` | wordpress
```WP_DB_HOST```     | ```MYSQL_PORT_3306_TCP_ADDR``` | db
```WP_DB_PORT```     | ```MYSQL_PORT_3306_TCP_PORT``` | 3306
```WP_DB_PREFIX```   | N/A                            | wp_

## Installation 
Uses ```wp core install```.

The initial DB is installed, if not already installed in the DB, using the variables; each has a useless default value, so make sure you set them:
- ```WP_LOCALE``` (default ```en_NZ```)
- ```WP_URL``` 
- ```WP_TITLE```
- ```WP_ADMIN_USER```
- ```WP_ADMIN_PASSWORD```
- ```WP_ADMIN_EMAIL```

## Themes and Plugins 
Uses ```wp theme install``` and ```wp plugin install```.

Themes and plugins can be installed from the WordPress.org repository, from a URL to the theme's or plugin's ZIP file. I.e.:

Each theme or plugin is on its own line.

    WP_THEMES: |
      theme-slug
      theme-slug http://theme.domain/theme-url.zip

    WP_PLUGINS: |
      plugin-slug
      plugin-slug https://plugin.domain/plugin-url.zip

Themes and plugins can also be installed from private [Bitbucket] repositories:

      BB_KEY: "BitBucket API OAuth Key"
      BB_SECRET: "BitBucket API OAuth Secret"
      BB_PLUGINS: |
        plugin-slug account/repo tag
      BB_THEMES: |
        theme-slug account/repo tag

One quirk of this method is that each version/tag of a theme or plugin will be installed to a unique directory derived from the account, repository, and  commit, e.g. account_repo_cafe6789. Any commit-ish should work.

[Bitbucket]: http://bitbucket "Bitbucket"

## Options
Uses ```wp option set```.

Any WordPress options can be set as JSON using ```WP_OPTIONS```. E.g.

    WP_OPTIONS: |
      timezone_string "Pacific/Auckland"
      permalink_structure "\/%postname%\/"
      some_complex_option {"access_key_id":"...","secret_access_key":"..."}

Simple strings must be quoted.

## Administration & Management

Use [WP-CLI] directly:

    docker exec -u www-data CONTAINER wp set option siteurl http://example.com

Run an interactive shell to administer the installation.

    docker exec -u www-data -it CONTAINER bash
    www-data@CONTAINER$ wp core check-update 
    www-data@CONTAINER$ wp core update
    www-data@CONTAINER$ wp core update-db

You can source the entrypoint script into the shell to use the functions defined within. Consult ```entrypoint.sh``` for documentation.

    docker exec -u www-data -it CONTAINER bash
    www-data@CONTAINER$ . /entrypoint.sh
    www-data@CONTAINER$ # Now install a new theme
    www-data@CONTAINER$ install_a theme <<< "theme-slug"
    www-data@CONTAINER$ # Now install a BB plugin
    www-data@CONTAINER$ install_b plugin <<< "plugin-slug account/repo tag"



