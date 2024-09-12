#!/usr/bin/env bash

msg_test() {
  builtin echo -en "\033[1;34m" >&1
  echo -n "===> "
  builtin echo -en "\033[1;36m" >&1
  echo -e "$@"
  builtin echo -en "\033[0m" >&1
}

msg_yellow() {
    builtin echo -en "\033[1;33m" >&1
    echo -e "$@"
    builtin echo -en "\033[0m" >&1
}

msg_green() {
  builtin echo -en "\033[1;32m" >&1
  echo -e "$@"
  builtin echo -en "\033[0m" >&1
}

msg_red() {
  builtin echo -en "\033[1;31m" >&2
  echo -e "$@"
  builtin echo -en "\033[0m" >&2
}

err_exit() {
  msg_red "$@"
  exit 1
}

wait_for() {
  local i=$1
  local char=${2:-.}
  while [ "$i" -gt 0 ]; do
    echo -n "$char"
    i=$(( i-1 ))
    sleep 1
  done
  echo
}

start_kong() {
  KONG_FIPS=off
  if [ "$SSL_PROVIDER" = "boringssl" ]; then
    KONG_FIPS=on
  fi
  KONG_FIPS=$KONG_FIPS KONG_TEST_IMAGE_NAME=${1:-$KONG_TEST_IMAGE_NAME} docker-compose -f "$TEST_COMPOSE_PATH" up -d
}

stop_kong() {
  KONG_TEST_IMAGE_NAME=${1:-$KONG_TEST_IMAGE_NAME} docker-compose -f "$TEST_COMPOSE_PATH" down
  KONG_TEST_IMAGE_NAME=${1:-$KONG_TEST_IMAGE_NAME} docker-compose -f "$TEST_COMPOSE_PATH" rm -f
  docker stop $(docker ps -a -q) || true
  docker rm $(docker ps -a -q) || true
  docker volume prune -f
}

kong_ready() {
  local TIMEOUT_SECONDS=$((5 * 60))
  while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' localhost:8000)" != 404 ]]; do
    sleep 5;
    COUNTER=$((COUNTER + 5))

    if (($COUNTER >= $TIMEOUT_SECONDS))
    then
      printf "\xe2\x98\x93 ERROR: Timed out waiting for $KONG"
      exit 1
    fi
  done
}

wait_kong() {
  while ! kong_ready; do
    msg_test "Waiting for Kong to be ready "
    docker-compose -f "$TEST_COMPOSE_PATH" ps
    docker-compose -f "$TEST_COMPOSE_PATH" logs kong
    sleep 5
  done
}

assert_response() {
  local endpoint=$1
  local expected_code=$2
  local resp_code
  COUNTER=20
  while : ; do
    resp_code=$(curl -s -o /dev/null -w "%{http_code}" $endpoint)
    [ "$resp_code" == "$expected_code" ] && break
    ((COUNTER-=1))
    [ "$COUNTER" -lt 1 ] && break
    sleep 0.5 # 10 seconds max
  done
  [ "$resp_code" == "$expected_code" ] || err_exit "  expected $2, got $resp_code"
}

it_runs_free_enterprise() {
  info=$(curl $KONG_ADMIN_URI)
  msg_test "it does not have ee-only plugins"
  [ "$(echo $info | jq -r .plugins.available_on_server.canary)" != "true" ]
  msg_test "it does not enable vitals"
  [ "$(echo $info | jq -r .configuration.vitals)" == "false" ]
  msg_test "workspaces are not writable"
  assert_response "$KONG_ADMIN_URI/workspaces -d name=testworkspace" "403"
}

it_runs_full_enterprise() {
  info=$(curl $KONG_ADMIN_URI)
  msg_test "it does have ee-only plugins"
  [ "$(echo $info | jq -r .plugins.available_on_server | jq -r 'has("canary")')" == "true" ]
  msg_test "it does enable vitals"
  [ "$(echo $info | jq -r .configuration.vitals)" == "true" ]
  msg_test "workspaces are writable"
  assert_response "$KONG_ADMIN_URI/workspaces -d name=testworkspace" "201"
}
