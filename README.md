WP-CLI installed, configured, and managed WordPress site.

Themes, plugins, and options can be specified as environment variables for configuration on start up.  The DB will be created if required and requires ```MYSQL_ENV_MYSQL_ROOT_PASSWORD``` be set.

Use ```:apache``` or ```:fpm``` as required.

E.g. docker-compose.yml or tutum.yml

    wp:
      image: nickbreen/wp-cli:apache
      mem_limit: 128m
      links: 
        - db:mysql
      volumes:
        - /var/www/html
      environment:
        VIRTUAL_HOST: "*.example.com"
        WP_DB_NAME: wp_example
        WP_DB_USER: wp_example
        WP_DB_PASSWORD: wp_example
        WP_LOCALE: en_NZ
        WP_URL: http://example.com
        WP_TITLE: Example Blog
        WP_ADMIN_USER: example
        WP_ADMIN_PASSWORD: example
        WP_ADMIN_EMAIL: example@example.com
        WP_PLUGINS: |
          amazon-s3-and-cloudfront
          amazon-web-services
          wordfence
        WP_OPTIONS: |
          timezone_string "Pacific/Auckland"
          permalink_structure "\/%postname%\/"
          aws_settings {"access_key_id":"PASTE_KEY_HERE","secret_access_key":"PASTE_SECRET_HERE"}
          tantan_wordpress_s3 {"post_meta_version":3,"bucket":"PASTE_BUCKET_NAME_HERE","region":"PASTE_REGION_HERE","domain":"path","expires":"0","cloudfront":"","object-prefix":"wp-content\/uploads\/","copy-to-s3":"1","serve-from-s3":"1","remove-local-file":"1","ssl":"request","hidpi-images":"0","object-versioning":"0","use-yearmonth-folders":"1","enable-object-prefix":"1"}
        BB_KEY: PASTE_BITBUCKET_KEY_HERE
        BB_SECRET: PASTE_BITBUCKET_SECRET_HERE
        BB_PLUGINS: |
          owner-name/repo-name tag
        BB_THEMES: |
          owner-name/repo-name tag
    db:
      image: mariadb
      command: --innodb_file_per_table
      environment:
        MYSQL_ROOT_PASSWORD: example

Run an interactive shell to use WP-CLI to administer the site.

    docker exec -u www-data CONTAINER wp set option siteurl http://example.com

or

    tutum exec -u www-data CONTAINER wp set option siteurl http://example.com

# Usage

Everything is specified using environment variables. See the example above.

## Download (```wp core download```)

The latest WordPress version will be downloaded and extracted.

## Configuration (``` wp core config```)

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

## Installation (```wp core install```)

The initial site is installed, if not already installed in the DB, using the variables; each has a useless default value, so make sure you set them:
- ```WP_LOCALE``` (default ```en_NZ```)
- ```WP_URL``` 
- ```WP_TITLE```
- ```WP_ADMIN_USER```
- ```WP_ADMIN_PASSWORD```
- ```WP_ADMIN_EMAIL```

## Themes and Plugins (```wp theme install``` and ```wp plugin install```)

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

Any WordPress options can be set as JSON using ```WP_OPTIONS```. E.g.

    WP_OPTIONS: |
      timezone_string "Pacific/Auckland"
      permalink_structure "\/%postname%\/"
      some_complex_option {"access_key_id":"...","secret_access_key":"..."}

Simple strings must be quoted.