#!/usr/bin/env bash

function run_test {
  # the suite name below will only be used when rtunning this file directly, when
  # running through "test.sh" it must be provided using the "--suite" option.
  tinitialize "Docker-Kong test suite" "${BASH_SOURCE[0]}"

  tchapter "makes executables available"

  ttest "resty is in the system path"
  docker run -ti --rm "kong-$BASE" resty -V
  if [ $? -eq 0 ]; then
    tsuccess
  else
    tmessage "resty wasn't found in the system path"
    tfailure
  fi

  ttest "luajit is in the system path"
  docker run -ti --rm "kong-$BASE" luajit -v
  if [ $? -eq 0 ]; then
    tsuccess
  else
    tmessage "luajit wasn't found in the system path"
    tfailure
  fi

  ttest "lua is in the system path"
  docker run -ti --rm "kong-$BASE" lua -v
  if [ $? -eq 0 ]; then
    tsuccess
  else
    tmessage "lua wasn't found in the system path"
    tfailure
  fi

  ttest "nginx is in the system path"
  docker run -ti --rm "kong-$BASE" nginx -v
  if [ $? -eq 0 ]; then
    tsuccess
  else
    tmessage "nginx wasn't found in the system path"
    tfailure
  fi

  ttest "luarocks is in the system path"
  docker run -ti --rm "kong-$BASE" luarocks --version
  if [ $? -eq 0 ]; then
    tsuccess
  else
    tmessage "luarocks wasn't found in the system path"
    tfailure
  fi

  tfinish
}

# No need to modify anything below this comment

# shellcheck disable=SC1090  # do not follow source
[[ "$T_PROJECT_NAME" == "" ]] && set -e && if [[ -f "${1:-$(dirname "$(realpath "$0")")/test.sh}" ]]; then source "${1:-$(dirname "$(realpath "$0")")/test.sh}"; else source "${1:-$(dirname "$(realpath "$0")")/run.sh}"; fi && set +e
run_test
