#!/bin/sh
set -e

export KONG_NGINX_DAEMON=off

if [[ "$1" == "kong" ]]; then
  PREFIX=${KONG_PREFIX:=/usr/local/kong}

  if [[ "$2" == "docker-start" ]]; then
    chown kong "$PREFIX"
    su kong -c "kong prepare -p '$PREFIX'"
    
    setcap cap_net_raw=+ep /usr/local/openresty/nginx/sbin/nginx

    chmod 777 /proc/self/fd/1
    chmod 777 /proc/self/fd/2

    su kong -c "/usr/local/openresty/nginx/sbin/nginx \
      -p '$PREFIX' \
      -c nginx.conf"
  fi
fi

exec "$@"
