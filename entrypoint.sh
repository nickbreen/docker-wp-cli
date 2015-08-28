#!/bin/bash

function install {
  [ "$VERBOSE" ] && echo Installing

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
    php /oauth.php --key "$BB_KEY" --secret "$BB_SECRET" --url "$URL" > $ZIP
    wp theme install $ZIP
    # TODO rename the top level directory from the zip
  done

  [ "$VERBOSE" ] && wp theme list

  # Install plugins

  for P in $WP_PLUGINS; do
    wp plugin is-installed $P || wp plugin install $P
  done
  wp plugin activate --all

  for URL in $BB_PLUGINS; do
    ZIP=wp-content/plugins/$(basename "$URL")
    php /oauth.php --key "$BB_KEY" --secret "$BB_SECRET" --url "$URL" > $ZIP
    wp plugin install $ZIP
    # TODO rename the top level directory from the zip
  done

  [ "$VERBOSE" ] && wp plugin list
}

function upgrade {
  [ "$VERBOSE" ] && echo Upgrading
  wp core update \
      && wp core update-db \
      && wp theme update --all \
      && wp plugin update --all

  # TODO fetch [a specific] tagged download from BB
}

function import {
  [ "$VERBOSE" ] && echo Importing
  [ "$VERBOSE" ] && echo Found WXR files to import
  [ "$VERBOSE" ] && ls -1 $SITE/wxr/*.xml

  wp plugin install wordpress-importer --activate

  wp import $SITE/wxr/*.xml --authors=create --skip=image_resize

  wp option update siteurl "$WP_URL"
  wp option update home "$WP_URL"
}

# TODO remove
SITE=$(dirname $(readlink -nf "$0"))
export GIT_SSH=$SITE/ssh.sh

while getopts iumv OPT; do
  case $OPT in
    i) ACTION='install';;
    u) ACTION='upgrade';;
    m) ACTION='import';;
    v) VERBOSE=true;;
    *) exit 1
  esac
done

$ACTION

"${@:$OPTIND}"
