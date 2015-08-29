#!/bin/bash

function log {
  [ ! -t 0 ] && LOG=$(</dev/stdin)
  if [ "$VERBOSE" ]
  then
    [ ${#@} -gt 0 ] && echo "$@"
    [ ${#LOG} -gt 0 ] && echo "$LOG"
  fi
}

function bb {
  php /oauth.php --key "$BB_KEY" --secret "$BB_SECRET" --url "$1" > $2
}

function install {
  log Installing

  # Install core [configuration]

  wp core is-installed || wp core install \
      --url="$WP_URL" \
      --title="$WP_TITLE" \
      --admin_user="$WP_ADMIN_USER" \
      --admin_password="$WP_ADMIN_PASSWORD" \
      --admin_email="$WP_ADMIN_EMAIL"

  # Install themes

  for T in $WP_THEMES; do
    wp theme is-installed $T || wp theme install $T
  done

  for THEME in $EXT_THEMES; do
    IFS=, read -ra T <<< "$THEME"
    wp theme is-installed ${T[0]} || wp theme install "${T[1]}"
  done

  for URL in $BB_THEMES; do
    ZIP=wp-content/themes/$(basename "$URL")
    bb $URL $ZIP
    wp theme install $ZIP
    # TODO rename the top level directory from the zip
  done

  wp theme list | log

  # Install plugins

  for P in $WP_PLUGINS; do
    wp plugin is-installed $P || wp plugin install $P
  done
  wp plugin activate --all

  for URL in $BB_PLUGINS; do
    ZIP=wp-content/plugins/$(basename "$URL")
    bb $URL $ZIP
    wp plugin install $ZIP
    # TODO rename the top level directory from the zip
  done

  wp plugin list | log Plugins
}

function upgrade {
  log Upgrading
  wp core update \
      && wp core update-db \
      && wp theme update --all \
      && wp plugin update --all

  # TODO fetch [a specific] tagged download from BB
}

function import {
  log Importing

  wp plugin is-installed wordpress-importer || wp plugin wp plugin install wordpress-importer --activate
  [ $(wp plugin get wordpress-importer --field=status) -eq "active" ] || wp plugin activate wordpress-importer

  wp import $WP_IMPORT --authors=create --skip=image_resize

  wp option update siteurl "$WP_URL"
  wp option update home "$WP_URL"
}

# TODO remove $SITE
SITE=$(dirname $(readlink -nf "$0"))

while getopts v OPT; do
  case $OPT in
    v) VERBOSE=true;;
    *) exit 1
  esac
done

"${@:$OPTIND}"
