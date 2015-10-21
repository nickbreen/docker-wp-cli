#!/bin/bash

set -e

# Install New Relic PHP agent
# Assumes [ !-z "${NR_INSTALL_KEY}" ]
newrelic-install install
# Set the application name if specified
[ -z "${NR_APP_NAME}" ] || sed -i '/newrelic\.appname/ {s!".*"!"'"$NR_APP_NAME"'"!}' /usr/local/etc/php/conf.d/newrelic.ini

# Execute command.
exec "${@}"
