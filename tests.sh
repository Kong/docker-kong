#!/bin/bash

set -ex

# Test the proper version was buid
pushd $BASE
version_given="$(grep -o -P '(?<=-).*(?=})' build-ce.sh)"
version_built="$(docker run -ti --rm kong-$BASE kong version | tr -d '[:space:]')"

if [[ "$version_given" != "$version_built" ]]; then
  echo "Kong version mismatch:";
  echo "\tVersion given is $version_given";
  echo "\tVersion built is $version_built";
  exit 1;
fi

popd

# Docker swarm test

pushd compose
docker swarm init
KONG_DOCKER_TAG=kong:1.5.0 docker stack deploy -c<(curl -fsSL https://raw.githubusercontent.com/Kong/docker-kong/1.5.0/swarm/docker-compose.yml) kong
until docker ps | grep kong:1.5.0 | grep -q healthy;  do
  docker stack ps kong
  docker service ps kong_kong
  sleep 20
done

sleep 20
curl -I localhost:8001 | grep 'Server: openresty'
sed -i -e 's/127.0.0.1://g' docker-compose.yml
KONG_DOCKER_TAG=${KONG_DOCKER_TAG} docker stack deploy -c docker-compose.yml kong
sleep 20
until docker ps | grep ${KONG_DOCKER_TAG}:latest | grep -q healthy; do
  docker stack ps kong
  docker service ps kong_kong
  sleep 20
done

sleep 20
curl -I localhost:8001 | grep 'Server: openresty'

docker stack rm kong
sleep 20
docker swarm leave --force
docker volume prune -f
git checkout -- docker-compose.yml
popd

# Validate Kong is running as the Kong user
pushd compose
docker-compose up -d
until docker-compose ps | grep compose_kong_1 | grep -q "Up"; do sleep 1; done
sleep 20
docker-compose exec kong ps aux | sed -n 2p | grep -q kong
if [ $? -ne 0 ]; then
  echo "Kong is not running as the Kong user";
  echo "\tRunning instead as ";
  docker-compose exec kong ps aux | sed -n 2p
  exit 1;
fi

KONG_USER=1001 docker-compose up -d
until docker-compose ps | grep compose_kong_1 | grep -q "Up"; do sleep 1; done
sleep 20
docker-compose exec kong ps aux | sed -n 2p | grep -q 1001
if [ $? -ne 0 ]; then
  echo "Kong is not running as the overridden 1001 user";
  echo "\tRunning instead as ";
  docker-compose exec kong ps aux | sed -n 2p
  exit 1;
fi
docker-compose stop

popd

# Run Kong functional tests

git clone https://github.com/Kong/kong.git || true
pushd kong
git checkout $version_given
popd

pushd kong-build-tools
rm -rf test/tests/03-go-plugins
KONG_VERSION=$version_given KONG_TEST_IMAGE_NAME=kong-$BASE RESTY_IMAGE_TAG=$BASE make test
popd
