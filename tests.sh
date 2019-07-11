#!/bin/bash

set -e
set -x

# Test the proper version was buid
pushd $BASE
version_given="$(grep 'ENV KONG_VERSION' Dockerfile | awk '{print $3}' | tr -d '[:space:]')"
version_built="$(docker run -ti --rm kong-$BASE kong version | tr -d '[:space:]')"

if [[ "$version_given" != "$version_built" ]]; then
  echo "Kong version mismatch:";
  echo "\tVersion given is $version_given";
  echo "\tVersion built is $version_built";
  exit 1;
fi

# Test LuaRocks is functional for installing rocks
docker run -ti kong-$BASE /bin/sh -c "luarocks install version"
popd

# Docker swarm test

pushd swarm
docker swarm init
KONG_DOCKER_TAG=kong:1.0 docker stack deploy -c docker-compose.yml kong
until docker ps | grep kong:1.0 | grep -q healthy;  do
  docker stack ps kong
  docker service ps kong_kong
  sleep 10
done

docker stack deploy -c docker-compose.yml kong
sleep 5
until docker ps | grep kong:latest | grep -q healthy; do
  docker stack ps kong
  docker service ps kong_kong
  sleep 10
done

sleep 5
curl -I localhost:8001 | grep 'Server: openresty'

docker stack rm kong
sleep 10
docker swarm leave --force
docker volume prune -f
popd

# Validate Kong is running as the Kong user
pushd compose
docker-compose up -d
until docker-compose ps | grep compose_kong_1 | grep -q "healthy"; do sleep 1; done
sleep 10
docker-compose exec kong ps aux | sed -n 2p | grep -q kong
if [ $? -ne 0 ]; then
  echo "Kong is not running as the Kong user";
  echo "\tRunning instead as ";
  docker-compose exec kong ps aux | sed -n 2p
  exit 1;
fi
popd

# Run Kong functional tests

git clone https://github.com/Kong/kong.git
pushd kong
git checkout $version_given
popd

pushd kong-build-tools
TEST_HOST=`hostname --ip-address` KONG_VERSION=$version_given make run_tests
popd

pushd compose
docker-compose stop
KONG_USER=1001 docker-compose up -d
until docker-compose ps | grep compose_kong_1 | grep -q "healthy"; do sleep 1; done
sleep 10
docker-compose exec kong ps aux | sed -n 2p | grep -q 1001
if [ $? -ne 0 ]; then
  echo "Kong is not running as the overridden 1001 user";
  echo "\tRunning instead as ";
  docker-compose exec kong ps aux | sed -n 2p
  exit 1;
fi
popd
