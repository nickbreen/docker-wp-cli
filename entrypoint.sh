#!/bin/bash

function install {
  [ "$VERBOSE" ] && echo Installing
  wp core is-installed || wp core install \
      --url="$WP_URL" \
      --title="$WP_TITLE" \
      --admin_user="$WP_ADMIN_USER" \
      --admin_password="$WP_ADMIN_PASSWORD" \
      --admin_email="$WP_ADMIN_EMAIL"

  for T in $WP_THEMES; do
    wp theme is-installed $T || wp theme install $T
  done

  for THEME in $EXT_THEMES; do
    IFS=, read -ra T <<< "$THEME"
    wp theme is-installed ${T[0]} || wp theme install "${T[1]}"
  done

  wp theme is-installed CherryFramework || wp theme install http://www.cherryframework.com/releases/CherryFramework.zip
  #wp theme delete $(wp theme list --field=name | grep -ni 'CherryFramework|kidslink')
  [ "$VERBOSE" ] && wp theme list

  for P in $WP_PLUGINS; do
    wp plugin is-installed $P || wp plugin install $P
  done
  wp plugin activate --all
  [ "$VERBOSE" ] && wp plugin list
}

function upgrade {
  [ "$VERBOSE" ] && echo Upgrading
  wp core update \
      && wp core update-db \
      && wp theme update --all \
      && wp plugin update --all

  (cd wp-content/plugins/kidslink; git pull)
  (cd wp-content/themes/kidslink; git pull)
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

function deploy {
  [ "$VERBOSE" ] && echo Deploying

  ssh-agent bash -c " ; \
    echo ssh-add $SITE/key ; \
    git clone git@bitbucket.org:nickbreen/kidslink-plugin.git wp-content/plugins/kidslink ; \
    git clone git@bitbucket.org:nickbreen/kidslink-theme.git; wp-content/themes/kidslink ;\
  "
}


# TODO remove
SITE=$(dirname $(readlink -nf "$0"))
export GIT_SSH=$SITE/ssh.sh

while getopts iumdv OPT; do
  case $OPT in
    i) ACTION='install';;
    u) ACTION='upgrade';;
    m) ACTION='import';;
    d) ACTION='deploy';;
    v) VERBOSE=true;;
    *) exit 1
  esac
done

$ACTION

"${@:$OPTIND}"
