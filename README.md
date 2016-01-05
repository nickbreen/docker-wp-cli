
**Important**: the apache, fpm, cron, and wp-api tags have moved to their own projects.

- apache and fpm -> [nickbreen/wp-php](../nickbreen/wp-php)
- cron -> [nickbreen/cron](../nickbreen/cron)
- wp-api -> [nickbreen/wp-api](../nickbreen/wp-api)

# What are WordPress and WP-CLI?

[WordPress] is a free and open source blogging tool and a content management system (CMS) based on PHP and MySQL, which runs on a web hosting service. Features include a plugin architecture and a template system. WordPress is used by more than 22.0% of the top 10 million websites as of August 2013. WordPress is the most popular blogging system in use on the Web, at more than 60 million websites. The most popular languages used are English, Spanish and Bahasa Indonesia.

[WP-CLI] is a command line tool to administer a WordPress installation.

[WordPress]: https://wordpress.org "WordPress &#8250; Blog Tool, Publishing Platform, and CMS"
[WP-CLI]: http://wp-cli.org "A command line interface for WordPress"

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
```WP_DB_HOST```     | ```MYSQL_PORT_3306_TCP_ADDR``` | mysql
```WP_DB_PORT```     | ```MYSQL_PORT_3306_TCP_PORT``` | 3306
```WP_DB_PREFIX```   | N/A                            | wp_

```--extra-php``` is supported with the ```WP_EXTRA_PHP``` environment variable. E.g.

    WP_EXTRA_PHP: |
      define('DISABLE_WP_CRON', true);

*Important*! If you're -cheating- using ```ErrorDocument /index.php``` instead of mod_rewrite you'll /probably/ need to coerce WP into returning a normal 200 OK status.

    WP_EXTRA_PHP: |
      header("HTTP/1.1 200 OK");

This case is specifically noticed with WooCommerce.

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
      http://theme.domain/theme-url.zip

    WP_PLUGINS: |
      plugin-slug
      https://plugin.domain/plugin-url.zip

Themes and plugins can also be installed from [Bitbucket] and [GitHub] repositories:

      BB_KEY: "BitBucket API OAuth Key"
      BB_SECRET: "BitBucket API OAuth Secret"
      BB_PLUGINS: |
        account/repo [tag]
      BB_THEMES: |
        account/repo [tag]
      GH_TOKEN: xxxxxxxxx
      GH_THEME: |
        CherryFramework/CherryFramework

[Bitbucket]: https://bitbucket.com "Bitbucket"
[GitHub]: https://github.com "GitHub"

## Options
Uses ```wp option set```.

Any WordPress options can be set as JSON using ```WP_OPTIONS```. E.g.

    WP_OPTIONS: |
      timezone_string "Pacific/Auckland"
      some_complex_option {"access_key_id":"...","secret_access_key":"..."}

Simple strings must be quoted.

## Arbitrary WP-CLI Commands

Any WP-CLI command can be executed; e.g.:

    WP_COMMANDS: |
      rewrite structure /%postname%
      rewrite flush
