#!/bin/sh
set -e

# Disabling nginx daemon mode
export KONG_NGINX_DAEMON="off"

# Setting default prefix
export KONG_PREFIX="/usr/local/kong"

# Prepare Kong prefix
kong prepare -p ${KONG_PREFIX}

exec "$@"
