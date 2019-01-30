#!/bin/bash

set -e

pushd $BASE
version_given="$(grep 'ENV KONG_VERSION' Dockerfile | awk '{print $3}' | tr -d '[:space:]')"
version_built="$(docker run -ti --rm kong-$BASE kong version | tr -d '[:space:]')"

if [[ "$version_given" != "$version_built" ]]; then
  echo "Kong version mismatch:";
  echo "\tVersion given is $version_given";
  echo "\tVersion built is $version_built";
  exit 1;
fi

docker run -ti kong-$BASE luarocks install version

popd

pushd compose
docker-compose up -d
until docker-compose ps | grep compose_kong_1 | grep -q "Up"; do sleep 1; done

kong_user="$(docker-compose exec kong ps aux | sed -n 2p | awk '{print $1}')"
if [[ "$kong_user" != "kong" ]]; then
  echo "Kong is not running as the Kong user";
  echo "\tRunning instead as $kong_user";
  exit 1;
fi
