#!/bin/sh
set -e

if [[ "$1" == "kong" && "$2" =~ "start" ]]; then
  export KONG_NGINX_DAEMON=off
  PREFIX=${KONG_PREFIX:=/usr/local/kong}

  kong prepare -p $PREFIX &&
    exec /usr/local/openresty/nginx/sbin/nginx \
      -p $PREFIX \
      -c nginx.conf
fi

exec "$@"
