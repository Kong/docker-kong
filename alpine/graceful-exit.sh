#!/bin/sh

# wait for orchestration tools to become consistent
if [[ "$1" == "" ]]; then
  sleep 3
else
  sleep $1
fi

# gracefully exit Kong with a timeout
if [[ "$2" == "" ]]; then
  kong quit
else
  kong quit --timeout=$2
fi
