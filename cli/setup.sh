#!/bin/bash

set -e

WP=$(which wp)

# Dirty function alias for wp-cli
function wp {
	$WP --allow-root "$@"
}

# Juggle ENV VARS
echo MYSQL_ROOT_PASSWORD = ${MYSQL_ROOT_PASSWORD:=$MYSQL_ENV_MYSQL_ROOT_PASSWORD}
echo WP_DB_NAME = ${WP_DB_NAME:=$MYSQL_ENV_MYSQL_DATABASE}
echo WP_DB_USER = ${WP_DB_USER:=$MYSQL_ENV_MYSQL_USER}
echo WP_DB_PASSWORD = ${WP_DB_PASSWORD:=$MYSQL_ENV_MYSQL_PASSWORD}
echo WP_DB_HOST = ${WP_DB_HOST:=$MYSQL_PORT_3306_TCP_ADDR}
echo WP_DB_PORT = ${WP_DB_PORT:=$MYSQL_PORT_3306_TCP_PORT}

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
		if [ "$SLUG" ]
		then
			wp $A is-installed $SLUG || wp $A install ${URL:-$SLUG}
			wp $A activate $SLUG
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
# Note that a BitBucket ZIP contains a directory named for the project
# and the commit. E.g. some_theme_12345678
#
# To update or replace a theme or plugin:
# 1. Install the new theme/plugin. E.g. some_theme_90abcdef
# 2. Find the old directory with the matching prefix. E.g. some_theme_12345678
# 3. Deactivate the old theme/plugin. E.g. wp theme deactivate some_theme_12345678
# 4. Activate the new theme/plugin. E.g. wp theme activate some_theme_90abcdef
#
function install_b {
	local A=$1
	while read REPO TAG;
	do
		if [ "$REPO" ]
		then
			local URL="https://bitbucket.org/${REPO}/get/${TAG:-master}.zip"
			local ZIP="wp-content/${A}s/${REPO/\//.}.${TAG:-master}.zip"
			# TODO get tar.gz instead, normalise the root dir name to $SLUG
			#+ using tar --strip-component=1 -C $SLUG and then zip and install
			bb $URL > $ZIP || echo Tag does not exist for: $REPO @ ${TAG:-master} && wp $A install $ZIP --force
		fi
	done
}

# Dirty function to call the oauth.php script
function bb {
	php /oauth.php --key "$BB_KEY" --secret "$BB_SECRET" --url "$1"
}

function install_core {
	# Setup the database
	php /db.php

	# Always download the lastest WP
	wp core download --locale="${WP_LOCALE}" || true

	# Configure the database
	# Assume that a DB has already been created
	# Skip the DB check as there isn't a mysql client available
	rm -f wp-config.php
	wp core config \
			--skip-check \
			--locale="${WP_LOCALE}" \
			--dbname="${WP_DB_NAME}" \
			--dbuser="${WP_DB_USER}" \
			--dbpass="${WP_DB_PASSWORD}" \
			--dbhost="${WP_DB_HOST}:${WP_DB_PORT}" \
			--dbprefix="${WP_DB_PREFIX}" \
			--extra-php <<< "${WP_EXTRA_PHP}"

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
#	wp theme list
}

function install_plugins {
	install_a plugin <<< "$WP_PLUGINS"
	install_b plugin <<< "$BB_PLUGINS"
#	wp plugin list
}

# Sets options as specified in STDIN.
# Expects format of OPTION_NAME JSON_STRING
function options {
	while read OPTION JSON;
	do
		if [ "$OPTION" -a "$JSON" ]
		then
			wp option set "$OPTION" "$JSON" --format=json
		fi
	done <<< "$WP_OPTIONS"
}

# Allows execution of arbitrary WP-CLI commands.
# I suppose this is either quite dangerous and makes most of
# the rest of this script redundant.
function wp_commands {
	while read CMD;
	do
		[ -z "$CMD" ] || wp $CMD
	done <<< "$WP_COMMANDS"
}

function import {
	wp plugin is-installed wordpress-importer || install_a plugin <<< "wordpress-importer"
	wp plugin activate wordpress-importer
	# wp option update siteurl "$WP_URL"
	# wp option update home "$WP_URL"
	echo 'Importing, this may take a *very* long time.'
	wp import $WP_IMPORT --authors=create --skip=image_resize --quiet "$@"
}

install_core
install_themes
install_plugins
options
wp core update \
	&& wp core update-db \
	&& wp theme update --all \
	&& wp plugin update --all
wp_commands

# Allow WP to alter the rewrite rules
touch .htaccess

# Ensure proper ownership and permissions.
# 'nobody' owns the files,
chown -R nobody:www-data .
chmod -R g-w,o-rwx .
chmod -R g+w wp-content/uploads .htaccess
