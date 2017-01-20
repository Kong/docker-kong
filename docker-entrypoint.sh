#!/usr/local/bin/dumb-init /bin/bash
set -e

# Disabling nginx daemon mode
export KONG_NGINX_DAEMON="off"

[ -z "$KONG_NGINX_DAEMON" ] && export KONG_NGINX_DAEMON="off"

# Make sure kong processes won't be considered as running because of pid file
if [ $( ls -1 /usr/local/kong/*pid | wc -l ) -gt 0 ]
then
  rm /usr/local/kong/*pid
fi

exec "$@"
