Run a container with an interactive shell to use WP-CLI.

Initial WordPress installation:

    docker run 
      --name wp-cli \
      --link db:mysql \
      --volumes-from wp-data \
      -e WP_URL=http://some.domain/some-url \
      -e WP_TITLE="Blog Title" \
      -e WP_ADMIN_USER=user \
      -e WP_ADMIN_PASSWORD=password \
      -e WP_ADMIN_EMAIL=user@some.domain \
      -d nickbreen/wp_cli


    wp core install \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL"

Or use ```docker-compose```.

    wp_cli:
        image: nickbreen/wp-cli
        links:
          - db:mysql
        volumes:
          - ./wxr:/var/www/wxr:ro
        volumes_from:
          - wp
        environment:
          WP_URL: http://some.domain/some-url
          WP_TITLE: Blog Title
          WP_ADMIN_USER: user
          WP_ADMIN_PASSWORD: password
          WP_ADMIN_EMAIL: user@some.domain
          WP_IMPORT: /var/www/wxr
          WP_THEMES: |
            theme-slug
            theme-slug http://theme.domain/theme-url.zip
          WP_PLUGINS: |
            plugin-slug
            plugin-slug https://plugin.domain/plugin-url.zip
          BB_KEY: "BitBucket API OAuth Key"
          BB_SECRET: "BitBucket API OAuth Secret"
          BB_PLUGINS: |
            slug account/repo tag
          BB_THEMES: |
            slug account/repo tag


The images' entrypoint provides a few convenience functions:

- ```install```
  Configures WP with URL, title, admin details as specified by the ```WP_*``` and ```BB_*``` environment variables.
  ```BB_*``` installs from BitBucket.org, requires an API key and secret.
- ```upgrade```
  Upgrades WP, themes, and plugins.
- ```import```
  Imports all WXR files found in the WP_IMPORT directories (can also be files).

E.g.

    docker-compose run --rm -u www-data wp_cli install


Note: ```docker-compose``` 1.4.0 doesn't run with --volumes-from, so if you have a data container you must use docker proper.

    docker run \
      --name wp-cli \
      --link db:mysql \
      --volumes-from wp-data \
      -e WP_URL=http://some.domain/some-url \
      -e WP_TITLE="Blog Title" \
      -e WP_ADMIN_USER=user \
      -e WP_ADMIN_PASSWORD=password \
      -e WP_ADMIN_EMAIL=user@some.domain \
      -e WP_IMPORT=/var/www/wxr \
      -e WP_THEMES='
        theme-slug
        theme-slug http://theme.domain/theme-url.zip' \
      -e WP_PLUGINS:='
        plugin-slug
        plugin-slug https://plugin.domain/plugin-url.zip' \
      -e BB_KEY="BitBucket API OAuth Key" \
      -e BB_SECRET="BitBucket API OAuth Secret" \
      -e BB_PLUGINS='
        account/repo tag' \
      -e BB_THEMES='
        account/repo tag' \
      --rm -it \
      -u www-data \
      nickbreen/wp-cli install

