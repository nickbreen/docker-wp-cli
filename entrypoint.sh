#!/bin/bash

WP=$(which wp)
DEFAULT_BASE_DIR="/var/www/html"
DEFAULT_CONTENT_DIR=content
DEFAULT_WP_DIR=wordpress
INSTALL_DIR=$BASE_DIR/${WP_DIR:-$DEFAULT_WP_DIR}

function log {
  [ "$VERBOSE" ] && echo "$@"
}

# Dirty wrapper for wp-cli
function wp {
  $WP --allow-root --path=$INSTALL_DIR "$@"
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
  local A=$1
  while read SLUG URL;
  do
    if [ "$SLUG" -a "$URL" ]
    then
      wp $A is-installed $SLUG || wp $A install "$URL"
    elif [ "$SLUG" ]
    then
      wp $A is-installed $SLUG || wp $A install $SLUG
    fi
  done
}

# Installs themes or plugins specified on STDIN hosted at BitBucket.
# Usage:
#   install_b plugin|theme <<< "REPO TAG"
#
# REPO is the BitBucket account/repository value.
# TAG is any tag|branch|commitish
#
# Requires $BB_KEY and $BB_SECRET environment variables.
#
function install_b {
  local A=$1
  while read REPO TAG;
  do
    if [ "$REPO" ]
    then
      # TODO add support for the 'latest' tag by omission of the tag value
      local URL="https://bitbucket.org/${REPO}/get/${TAG}.zip"
      # TODO use a mktemp file for the ZIP and clean up afterwards
      local ZIP="wp-content/${A}s/${REPO/\//.}.${TAG}.zip"
      bb $URL > $ZIP || log Tag does not exist for: $REPO @ $TAG && wp $A install $ZIP --force
    fi
  done
}

# Dirty function to call the oauth.php script
function bb {
  php /oauth.php --key "$BB_KEY" --secret "$BB_SECRET" --url "$1"
}

function install_core {
  mkdir -p $INSTALL_DIR
  # Always download the lastest WP
  wp core download --locale="${WP_LOCALE:-en_NZ}" --force
  # Configure database 
  # Fallback to the linked mysql container if no explicit DB host is specified
  # Assume that a DB has already been created
  # Skip the DB check as there's unlikely to be a mysql client available
  wp core config \
      --skip-check \
      --dbname="${WORDPRESS_DB_NAME:-wordpress}" \
      --dbuser="$WORDPRESS_DB_USER" \
      --dbpass="$WORDPRESS_DB_PASSWORD" \
      --dbhost="${WORDPRESS_DB_HOST:-$MYSQL_PORT_3306_TCP_ADDR:$MYSQL_PORT_3306_TCP_PORT}" \
      --dbprefix="${WORDPRESS_DB_PREFIX:-wp_}" \
      --extra-php <<PHP
define('WP_HOME', '${WP_URL}' );
define('WP_CONTENT_DIR', dirname(__FILE__) . '/${WP_CONTENT_DIR:-$DEFAULT_CONTENT_DIR}');
define('WP_CONTENT_URL', WP_HOME . '/${WP_CONTENT_DIR:-$DEFAULT_CONTENT_DIR}');
PHP
  mv $INSTALL_DIR/wp-config.php $BASE_DIR
  mv $INSTALL_DIR/wp-content $BASE_DIR/${WP_CONTENT_DIR:-$DEFAULT_CONTENT_DIR}

  # Configure the Blog
  wp core is-installed || wp core install \
      --url="$WP_URL" \
      --title="$WP_TITLE" \
      --admin_user="$WP_ADMIN_USER" \
      --admin_password="$WP_ADMIN_PASSWORD" \
      --admin_email="$WP_ADMIN_EMAIL"
}

function install_themes {
  install_a theme <<< "$WP_THEMES"
  install_b theme <<< "$BB_THEMES"
  wp theme list
}

function install_plugins {
  install_a plugin <<< "$WP_PLUGINS"
  install_b plugin <<< "$BB_PLUGINS"
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
    log "Import requires the wordpress-importer plugin, please specifiy it in \$WP_PLUGINS"
    exit 1
  fi

  # wp option update siteurl "$WP_URL"
  # wp option update home "$WP_URL"
  echo 'Importing, this may take a *very* long time.'
  wp import $WP_IMPORT --authors=create --skip=image_resize --quiet "$@"
}

function usage {
  echo <<-EOT
    Usage: entrypoing.sh [-v] [command]
    
    Options:
    -v\t\tVerbose logging.

EOT
}

# Parse options
while getopts v OPT; do
  case $OPT in
    v) VERBOSE=true;;
    *) usage; exit 1
  esac
done

set -e
# Ensure proper ownership of the docroot
chown -cR www-data:www-data "${BASE_DIR:-$DEFAULT_BASE_DIR}"

# Execute default function or command.
"${@:$OPTIND}"
