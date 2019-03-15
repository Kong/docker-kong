#!/bin/sh
set -e

export KONG_NGINX_DAEMON=off

has_transparent() {
  echo "$1" | grep -E "[^\s,]+\s+transparent\b" >/dev/null
}

if [[ "$1" == "kong" ]]; then
  PREFIX=${KONG_PREFIX:=/usr/local/kong}

  if [[ "$2" == "docker-start" ]]; then
    shift 2

    if [ -f "/usr/local/openresty/nginx/sbin/nginx" ]
    then
      rm /usr/local/openresty/nginx/sbin/nginx
    fi 

    if [ ! -z ${SET_CAP_NET_RAW} ] \
        || has_transparent "$KONG_STREAM_LISTEN" \
        || has_transparent "$KONG_PROXY_LISTEN" \
        || has_transparent "$KONG_ADMIN_LISTEN";
    then
      ln -s /usr/local/openresty/nginx/sbin/nginx-transparent /usr/local/openresty/nginx/sbin/nginx
      kong prepare -p "$PREFIX" "$@"
      exec /usr/local/openresty/nginx/sbin/nginx \
      -p "$PREFIX" \
      -c nginx.conf
    else
      ln -s /usr/local/openresty/nginx/sbin/nginx-non-transparent /usr/local/openresty/nginx/sbin/nginx
      ls -al /usr/local/openresty/nginx/sbin/
      kong prepare -p "$PREFIX" "$@"
      exec /usr/local/openresty/nginx/sbin/nginx \
      -p "$PREFIX" \
      -c nginx.conf
    fi
  fi
fi

exec "$@"
