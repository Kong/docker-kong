#!/usr/bin/env bash

function run_test {
  tinitialize "Docker-Kong test suite" "${BASH_SOURCE[0]}"

  docker run -i --rm -v $PWD/hadolint.yaml:/.config/hadolint.yaml hadolint/hadolint:2.7.0 < $BASE/Dockerfile

  if [[ ! -z "${SNYK_SCAN_TOKEN}" ]]; then
    docker scan --accept-license --login --token "${SNYK_SCAN_TOKEN}"
    docker scan --accept-license --exclude-base --severity=high --file $BASE/Dockerfile kong-$BASE
  fi

  # Test the proper version was buid
  tchapter "test $BASE image"
  ttest "the proper version was build"

  pushd $BASE
  version_given="$(grep 'ARG KONG_VERSION' Dockerfile | awk -F "=" '{print $2}')"
  version_built="$(docker run -i --rm kong-$BASE kong version | tr -d '[:space:]')"

  if [[ "$version_given" != "$version_built" ]]; then
    echo "Kong version mismatch:";
    echo "\tVersion given is $version_given";
    echo "\tVersion built is $version_built";
    tfailure
  else
    tsuccess
  fi
  popd

  ttest "Dbless Test"
  
  pushd compose
  docker-compose up -d
  until docker ps -f health=healthy | grep -q ${KONG_DOCKER_TAG}; do
    docker-compose up -d
    docker ps
    sleep 15
  done
  
  curl -I localhost:8001 | grep -E '(openresty|kong)'
  if [ $? -eq 0 ]; then
    tsuccess
  else
    tfailure
  fi
  
  docker-compose kill
  docker-compose rm -f
  sleep 5
  docker volume prune -f
  popd

  ttest "Upgrade Test"

  export COMPOSE_PROFILES=database
  export KONG_DATABASE=postgres
  pushd compose
  curl -fsSL https://raw.githubusercontent.com/Kong/docker-kong/1.5.0/swarm/docker-compose.yml | KONG_DOCKER_TAG=kong:1.5.0 docker-compose -p kong -f - up -d
  until docker ps -f health=healthy | grep -q kong:1.5.0;  do
    curl -fsSL https://raw.githubusercontent.com/Kong/docker-kong/1.5.0/swarm/docker-compose.yml | docker-compose -p kong -f - ps
    docker ps
    sleep 15
    curl -fsSL https://raw.githubusercontent.com/Kong/docker-kong/1.5.0/swarm/docker-compose.yml | KONG_DOCKER_TAG=kong:1.5.0 docker-compose -p kong -f - up -d
  done
  curl -I localhost:8001 | grep 'Server: openresty'
  sed -i -e 's/127.0.0.1://g' docker-compose.yml
  
  KONG_DOCKER_TAG=${KONG_DOCKER_TAG} docker-compose -p kong up -d
  until docker ps -f health=healthy | grep -q ${KONG_DOCKER_TAG}; do
    docker-compose -p kong ps
    docker ps
    sleep 15
  done

  curl -I localhost:8001 | grep -E '(openresty|kong)'
  if [ $? -eq 0 ]; then
    tsuccess
  else
    tfailure
  fi
  
  echo "cleanup"

  docker-compose -p kong kill
  docker-compose -p kong rm -f
  sleep 5
  docker volume prune -f
  docker system prune -y
  git checkout -- docker-compose.yml
  popd

  # Validate Kong is running as the Kong user (default)
  ttest "Kong is running as the Kong user (default)"

  pushd compose
  docker-compose up -d
  until docker-compose ps | grep compose_kong_1 | grep -q "Up"; do sleep 1; done
  sleep 20
  docker-compose exec kong ps aux | sed -n 2p | grep -q kong
  if [ $? -ne 0 ]; then
    echo "Kong is not running as the Kong user";
    echo "\tRunning instead as ";
    docker-compose exec kong ps aux | sed -n 2p
    tfailure
  else
    tsuccess
  fi


  # Validate Kong is running as the Kong user (overridden)
  ttest "Kong is running as the Kong user (overridden)"

  KONG_USER=1001 docker-compose up -d
  until docker-compose ps | grep compose_kong_1 | grep -q "Up"; do sleep 1; done
  sleep 20
  docker-compose exec kong ps aux | sed -n 2p | grep -q 1001
  if [ $? -ne 0 ]; then
    echo "Kong is not running as the overridden 1001 user";
    echo "\tRunning instead as ";
    docker-compose exec kong ps aux | sed -n 2p
    tfailure
  else
    tsuccess
  fi
  docker-compose stop

  popd



  # Run Kong functional tests
  ttest "Kong functional test"

  git clone https://github.com/Kong/kong.git || true
  pushd kong
  git checkout $version_given || git checkout next
  popd

  pushd kong-build-tools
  rm -rf test/tests/01-package
  docker tag kong-$BASE $BASE:$BASE
  KONG_VERSION=$version_given KONG_TEST_IMAGE_NAME=kong-$BASE RESTY_IMAGE_BASE=$BASE RESTY_IMAGE_TAG=$BASE make test
  if [ $? -eq 0 ]; then
    tsuccess
  else
    tfailure
  fi
  popd


  tfinish
}

# No need to modify anything below this comment

# shellcheck disable=SC1090  # do not follow source
[[ "$T_PROJECT_NAME" == "" ]] && set -e && if [[ -f "${1:-$(dirname "$(realpath "$0")")/test.sh}" ]]; then source "${1:-$(dirname "$(realpath "$0")")/test.sh}"; else source "${1:-$(dirname "$(realpath "$0")")/run.sh}"; fi && set +e
run_test
