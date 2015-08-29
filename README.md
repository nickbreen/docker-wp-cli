Go crazy and configure everything in environment variables! Note you'll need
to bind the volumes from a ```wordpress:fpm``` or similar process.

    wp-cli:
      build: wp-cli
      links:
        - db:mysql
      volumes:
        - ./wxr:/var/www/wxr:ro
      volumes_from:
        - wp
      environment:
        SITE: /var/www/site
        WP_URL: http://some.domain/some-url
        WP_TITLE: Blog Title
        WP_ADMIN_USER: user
        WP_ADMIN_PASSWORD: password
        WP_ADMIN_EMAIL: user@some.domain
        WP_IMPORT: /var/www/wxr
        WP_THEMES: |
          theme-slug http://theme.domain/theme-url.zip
        WP_PLUGINS: |
          hello-dolly
          jetpack
          wordpress-importer
          plugin-slug https://plugin.domain/plugin-url.zip
        BB_KEY: "BitBucket API OAuth Key"
        BB_SECRET: "BitBucket API OAuth Secret"
        BB_PLUGINS: |
          https://bitbucket.org/nickbreen/kidslink-plugin/get/v1.5.7.zip
        BB_THEMES: |
          https://bitbucket.org/nickbreen/kidslink-theme/get/v1.5.4.zip
