#!/bin/sh

# Setting up the proper database
if [ -z "$DATABASE" ]; then
  DATABASE="cassandra"
fi

echo -e '\ndatabase: "'$DATABASE'"' >> /etc/kong/kong.yml

cat /etc/kong/kong.yml
