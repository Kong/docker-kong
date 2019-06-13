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

    chmod o+w /proc/self/fd/1
    chmod o+w /proc/self/fd/2

    caps=""

    if [ -n "${SET_CAP_NET_RAW}" ] \
        || has_transparent "$KONG_STREAM_LISTEN" \
        || has_transparent "$KONG_PROXY_LISTEN" \
        || has_transparent "$KONG_ADMIN_LISTEN";
    then
      caps="${caps:+"${caps}",}cap_net_raw"
    fi

    if [ -n "${SET_CAP_NET_BIND_SERVICE}" ] ; then
      caps="${caps:+"${caps}",}cap_net_bind_service"
    fi

    if [ -n "${caps}" ] ; then
      setcap "${caps}=+ep" /usr/local/openresty/nginx/sbin/nginx
    fi
  fi
fi

exec "$@"
