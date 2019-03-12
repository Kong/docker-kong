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
    kong prepare -p "$PREFIX" "$@"

    if [ ! -z ${SET_CAP_NET_RAW} ] \
        || has_transparent "$KONG_STREAM_LISTEN" \
        || has_transparent "$KONG_PROXY_LISTEN" \
        || has_transparent "$KONG_ADMIN_LISTEN";
    then
      setcap cap_net_raw=+ep /usr/local/openresty/nginx/sbin/nginx
    fi

    /usr/local/openresty/nginx/sbin/nginx \
      -p "$PREFIX" \
      -c nginx.conf
  fi
fi

exec "$@"
