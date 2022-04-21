#!/usr/bin/env bash

# to run this test locally do the following:
# > docker pull kong:latest
# > docker tag kong:latest kong-alpine
# > BASE=alpine tests/02-customize.test.sh


function build_custom_image {
  # arg1: plugins; eg. "kong-http-to-https,kong-upstream-jwt"
  # arg2: template; eg. "/mykong/nginx.conf"
  # arg3: path to local rockserver dir; eg. "/some/dir/rockserver"
  local plugins
  local template
  local rockserver
  if [[ ! "$1" == "" ]]; then
    plugins="--build-arg PLUGINS=$1"
  fi
  if [[ ! "$2" == "" ]]; then
    cp $2 ./custom.conf
    template="--build-arg TEMPLATE=./custom.conf"
  fi
  if [[ ! "$3" == "" ]]; then
    # rockserver must be within docker build context, so copy files there
    mkdir rockserver
    ls $3
    cp -r -v "$3" .
    rockserver="--build-arg ROCKS_DIR=./rockserver"
  fi
  #export BUILDKIT_PROGRESS=plain
  docker build --build-arg KONG_BASE="kong-$BASE" \
               --build-arg "KONG_LICENSE_DATA=$KONG_LICENSE_DATA" \
               $plugins \
               $template \
               $rockserver \
               --tag "kong-$BASE-customize" \
               .
  local result=$?
  # cleanup the temporary files/directories
  if [ -d rockserver ]; then
    rm -rf rockserver
  fi
  if [ -f custom.conf ]; then
    rm custom.conf
  fi
  return $result
}

function delete_custom_image {
  docker rmi "kong-$BASE-customize" > /dev/null 2>&1
}

unset TEST_CMD_OPTS
function run_kong_cmd {
  docker run -ti --rm $TEST_CMD_OPTS "kong-$BASE-customize" $1
}



function run_test {
  # the suite name below will only be used when rtunning this file directly, when
  # running through "test.sh" it must be provided using the "--suite" option.
  tinitialize "Docker-Kong test suite" "${BASH_SOURCE[0]}"

  local mypath
  mypath=$(dirname "$(realpath "$0")")
  pushd "$mypath/../customize"



  tchapter "Customize $BASE"

  ttest "injects a plugin, pure-Lua"
  local test_plugin_name="kong-upstream-jwt"
  build_custom_image "$test_plugin_name"
  if [ ! $? -eq 0 ]; then
    tfailure
  else
    run_kong_cmd "luarocks list --porcelain" | grep $test_plugin_name
    if [ ! $? -eq 0 ]; then
      tmessage "injected plugin '$test_plugin_name' was not found"
      tfailure
    else
      tsuccess
    fi
  fi
  delete_custom_image



  ttest "injects a plugin, with self-contained C code (no binding)"
  local test_plugin_name="lua-protobuf"
  build_custom_image "$test_plugin_name"
  if [ ! $? -eq 0 ]; then
    tfailure
  else
    run_kong_cmd "luarocks list --porcelain" | grep $test_plugin_name
    if [ ! $? -eq 0 ]; then
      tmessage "injected plugin '$test_plugin_name' was not found"
      tfailure
    else
      tsuccess
    fi
  fi
  delete_custom_image



  ttest "injects a plugin with local rockserver"
  local test_plugin_name="kong-plugin-myplugin"
  build_custom_image "$test_plugin_name" "" "$mypath/rockserver"
  if [ ! $? -eq 0 ]; then
    tfailure
  else
    run_kong_cmd "luarocks list --porcelain" | grep $test_plugin_name
    if [ ! $? -eq 0 ]; then
      tmessage "injected plugin '$test_plugin_name' was not found"
      tfailure
    else
      tsuccess
    fi
  fi
  delete_custom_image



  ttest "build image to test KONG_PLUGINS settings"
  local test_plugin_name="kong-plugin-myplugin"
  build_custom_image "$test_plugin_name" "" "$mypath/rockserver"
  if [ ! $? -eq 0 ]; then
    tfailure
  else
    tsuccess
  fi

  ttest "injected plugin are added to KONG_PLUGINS if not set"
  unset TEST_CMD_OPTS
  run_kong_cmd "printenv" | grep "bundled,myplugin"
  if [ ! $? -eq 0 ]; then
    tmessage "injected plugin '$test_plugin_name' was not found in KONG_PLUGIN"
    tfailure
  else
    tsuccess
  fi

  ttest "injected plugin are added to KONG_PLUGINS if set with 'bundled'"
  TEST_CMD_OPTS="-e KONG_PLUGINS=bundled,custom-one"
  run_kong_cmd "printenv" | grep "bundled,myplugin,custom-one"
  if [ ! $? -eq 0 ]; then
    tmessage "injected plugin '$test_plugin_name' was not found in KONG_PLUGIN"
    tfailure
  else
    tsuccess
  fi

  ttest "injected plugin are NOT added to KONG_PLUGINS if set without 'bundled'"
  TEST_CMD_OPTS="-e KONG_PLUGINS=custom-one,custom-two"
  run_kong_cmd "printenv" | grep "$test_plugin_name"
  if [ $? -eq 0 ]; then
    tmessage "injected plugin '$test_plugin_name' was found in KONG_PLUGIN, but was not expected"
    tfailure
  else
    tsuccess
  fi

  # cleanup
  unset TEST_CMD_OPTS
  delete_custom_image



  ttest "fails injecting an unavailable plugin with local rockserver"
  # the plugin is PUBLICLY available, but NOT on our local one, so should fail
  local test_plugin_name="kong-upstream-jwt"
  build_custom_image "$test_plugin_name" "" "$mypath/rockserver"
  if [ ! $? -eq 0 ]; then
    tsuccess
  else
    tmessage "injected plugin '$test_plugin_name' which was not on the local rockserver"
    tfailure
  fi
  delete_custom_image



  ttest "injects a custom template"
  build_custom_image "" "$mypath/bad_file.conf"
  if [ ! $? -eq 0 ]; then
    tfailure
  else
    docker run -it -d \
      -e "KONG_DATABASE=off" \
      --name "kong-testsuite-container" \
      "kong-$BASE-customize:latest" kong start

    sleep 3
    OUTPUT=$(docker logs kong-testsuite-container)
    echo "$OUTPUT"
    echo "$OUTPUT" | grep "nginx configuration is invalid"

    if [ $? -eq 0 ]; then
      tmessage "container failed to start because of invalid config, as expected"
      tsuccess
    else
      tmessage "container is running, while it should have failed to start"
      tfailure
    fi
    docker rm --force kong-testsuite-container
  fi
  delete_custom_image



  ttest "injects a custom template and a plugin"
  local test_plugin_name="kong-plugin-myplugin"
  build_custom_image "$test_plugin_name" "$mypath/bad_file.conf" "$mypath/rockserver"
  if [ ! $? -eq 0 ]; then
    tfailure
  else
    # check if plugin was injected
    run_kong_cmd "luarocks list --porcelain" | grep $test_plugin_name
    if [ ! $? -eq 0 ]; then
      tmessage "injected plugin '$test_plugin_name' was not found"
      tfailure
    else
      # now check if the template was added
      docker run -it -d \
        -e "KONG_DATABASE=off" \
        --name "kong-testsuite-container" \
        "kong-$BASE-customize:latest" kong start

      sleep 3
      OUTPUT=$(docker logs kong-testsuite-container)
      echo "$OUTPUT"
      echo "$OUTPUT" | grep "nginx configuration is invalid"

      if [ $? -eq 0 ]; then
        tmessage "container failed to start because of invalid config, as expected"
        tsuccess
      else
        tmessage "container is running, while it should have failed to start"
        tfailure
      fi
      docker rm --force kong-testsuite-container
    fi
  fi
  delete_custom_image



  popd
  tfinish
}


# No need to modify anything below this comment

# shellcheck disable=SC1090  # do not follow source
[[ "$T_PROJECT_NAME" == "" ]] && set -e && if [[ -f "${1:-$(dirname "$(realpath "$0")")/test.sh}" ]]; then source "${1:-$(dirname "$(realpath "$0")")/test.sh}"; else source "${1:-$(dirname "$(realpath "$0")")/run.sh}"; fi && set +e
run_test
