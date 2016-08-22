#!/usr/local/bin/dumb-init /bin/bash
set -e

# Disabling nginx daemon mode
export KONG_NGINX_DAEMON="off"

# Setting the default Postgres database address
[ -z "$KONG_PG_HOST" ] && export KONG_PG_HOST="kong-database"

# Setting the default Cassandra database address
[ -z "$KONG_CASSANDRA_CONTACT_POINTS" ] && export KONG_CASSANDRA_CONTACT_POINTS="kong-database"

exec "$@"