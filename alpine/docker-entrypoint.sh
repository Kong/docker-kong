#!/bin/sh
set -e

if [[ "$1" == "kong" ]]; then
  PREFIX=${KONG_PREFIX:=/usr/local/kong}
  mkdir -p $PREFIX

  if [[ "$2" == "start" || "$2" == "restart" ]]; then
    export KONG_NGINX_DAEMON=off
    kong prepare -p $PREFIX

    exec /usr/local/openresty/nginx/sbin/nginx \
      -p $PREFIX \
      -c nginx.conf
  fi
fi

exec "$@"
