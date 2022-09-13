#!/usr/bin/env bash

function run_test {
  tinitialize "Docker-Kong test suite" "${BASH_SOURCE[0]}"

  # detect which type of image we're building
  # 1) less than 3.0, <os>/Dockerfile or
  # 2) greater than 3.0, Dockerfile.<package type>
  #
  # ideally there's smarter logic, but right now, the logic containing the
  # image tag being built and tested are scattered across this and more repos,
  # and assume a "kong-" prefix
  if [[ -f Dockerfile.$BASE ]]; then
    docker run -i --rm -v $PWD/hadolint.yaml:/.config/hadolint.yaml hadolint/hadolint:2.7.0 < Dockerfile.$BASE
  fi
  
  if [[ -f $BASE/Dockerfile ]]; then
    docker run -i --rm -v $PWD/hadolint.yaml:/.config/hadolint.yaml hadolint/hadolint:2.7.0 < $BASE/Dockerfile
  fi

  # set KONG_DOCKER_TAG to kong-$BASE (if not already set)
  export KONG_DOCKER_TAG="${KONG_DOCKER_TAG:-kong-$BASE}"

  if [[ ! -z "${SNYK_SCAN_TOKEN}" ]]; then
    docker scan --accept-license --login --token "${SNYK_SCAN_TOKEN}"
    docker scan --accept-license --exclude-base --severity=high --file $BASE/Dockerfile kong-$BASE
  fi

  # Test the proper version was buid
  tchapter "test $BASE image"
  ttest "the proper version was build"

  if [[ -f Dockerfile.$BASE ]]; then
    version_given="$(grep 'ARG KONG_VERSION' Dockerfile.$BASE | awk -F "=" '{print $2}')"
  fi
  
  if [[ -f $BASE/Dockerfile ]]; then
    version_given="$(grep 'ARG KONG_VERSION' $BASE/Dockerfile | awk -F "=" '{print $2}')"
  fi
  
  version_built="$(docker run -i --rm kong-$BASE kong version | tr -d '[:space:]')"

  if [[ "$version_given" != "$version_built" ]]; then
    echo "Kong version mismatch:";
    echo "\tVersion given is $version_given";
    echo "\tVersion built is $version_built";
    tfailure
  else
    tsuccess
  fi

  ttest "Dbless Test"

  function retry_health() {
    # 40 retries at 3 secs each = 120 seconds = 2 mins
    local retry=0 retries=40

    until docker ps -f health=healthy | grep -q "${KONG_DOCKER_TAG}"; do
      if [ $retry -ge $retries ]; then
        echo
        return 2
      fi
      echo -n '.'
      sleep 3
      retry=$(( retry + 1 ))
    done
    echo
  }

  pushd compose
  docker-compose up -d
  retry_health

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

  # Run Kong functional tests
  ttest "Kong functional test"

  git clone https://github.com/Kong/kong.git || true
  pushd kong
  git checkout $version_given || git checkout next
  popd

  pushd kong-build-tools
  rm -rf test/tests/01-package
  docker tag kong-$BASE kong/kong:amd64-test
  KONG_TEST_CONTAINER_TAG=test KONG_VERSION=$version_given KONG_TEST_IMAGE_NAME=kong-$BASE RESTY_IMAGE_BASE=$BASE RESTY_IMAGE_TAG=$BASE make test
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
