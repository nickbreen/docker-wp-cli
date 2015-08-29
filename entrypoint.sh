#!/bin/bash

function log {
  [ -t 0 ] || LOG=$(</dev/stdin)
  if [ "$VERBOSE" ]
  then
    [ ${#@} -gt 0 ] && echo "$@"
    [ ${#LOG} -gt 0 ] && echo "$LOG"
  fi
}

# Fetches a BitBucket URL using 2-legged OAuth  credentials.
#
#
function bb {
  php /oauth.php --key "$BB_KEY" --secret "$BB_SECRET" --url "$1" > $2
}

function install_core {
  wp core is-installed || wp core install \
      --url="$WP_URL" \
      --title="$WP_TITLE" \
      --admin_user="$WP_ADMIN_USER" \
      --admin_password="$WP_ADMIN_PASSWORD" \
      --admin_email="$WP_ADMIN_EMAIL"
}

# Installs themes or plugins from a list on STDIN.
#
# STDIN format each line: slug [URL]
# E.g.
#   hello-dolly
#   wordpress-importer
#   some-other-plugin http://some.other/plugin.zip
#
# Usage:
#   install_a plugin <<< "plugin_slug plugin_url"
#   install_a theme <<-EOT
#     theme_slug1
#     theme_slug2 http://theme_url2
#   EOT
#
function install_a {
  while read SLUG URL;
  do
    if [ "$SLUG" -a "$URL" ]
    then
      wp $1 is-installed $SLUG || wp $1 install "$URL"
    elif [ "$SLUG" ]
    then
      wp $1 is-installed $SLUG || wp $1 install $SLUG
    fi
  done
}

function install_themes {
  install_a theme <<< "$WP_THEMES"

  for URL in $BB_THEMES; do
    ZIP=wp-content/themes/$(basename "$URL")
    bb $URL $ZIP
    wp theme install $ZIP
    # TODO rename the top level directory from the zip
  done

  wp theme list
}

function install_plugins {
  # for P in $WP_PLUGINS; do
  #   wp plugin is-installed $P || wp plugin install $P
  # done
  install_a plugin <<< "$WP_PLUGINS"

  for URL in $BB_PLUGINS; do
    ZIP=wp-content/plugins/$(basename "$URL")
    bb $URL $ZIP
    wp plugin install $ZIP
    # TODO rename the top level directory from the zip
  done

  wp plugin list
}

function install {
  install_core
  install_themes
  install_plugins
  wp plugin activate --all
}

function upgrade {
  wp core update \
      && wp core update-db \
      && wp theme update --all \
      && wp plugin update --all

  # TODO fetch [a specific] tagged download from BB
}

function import {
  if ! wp plugin is-installed wordpress-importer
  then
    log "Import requires the wordpress-importer plugin, please spcifiy it in \$WP_PLUGINS"
    exit 1
  fi

  wp option update siteurl "$WP_URL"
  wp option update home "$WP_URL"
  echo Importing, this may take a very long time.
  wp import $WP_IMPORT --authors=create --skip=image_resize --skip=attachments --quiet
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
