#!/usr/local/bin/dumb-init /bin/bash
set -e

# Make a pipe for the logs so we can ensure Kong logs get directed to docker logging
# see https://github.com/docker/docker/issues/6880
# also, https://github.com/docker/docker/issues/31106, https://github.com/docker/docker/issues/31243
# https://github.com/docker/docker/pull/16468, https://github.com/behance/docker-nginx/pull/51
rm -f /tmp/logpipe
mkfifo -m 666 /tmp/logpipe
# This child process will still receive signals as per https://github.com/Yelp/dumb-init#session-behavior
cat <> /tmp/logpipe 1>&2 &

# Disabling nginx daemon mode
export KONG_NGINX_DAEMON="off"

exec "$@"
