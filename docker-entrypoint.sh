#!/bin/bash
set -e

# Setting up the proper database
if [ -n "$DATABASE" ]; then
  echo -e '\ndatabase: "'$DATABASE'"' >> /etc/kong/kong.yml
fi

# Make sure kong processes won't be considered as running because of pid file
if [ $( ls -1 /usr/local/kong/*pid | wc -l ) -gt 0 ]
then
  rm /usr/local/kong/*pid
fi

exec "$@"
