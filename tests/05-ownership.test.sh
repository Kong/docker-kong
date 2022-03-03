#!/usr/bin/env bash

function run_test {
  # the suite name below will only be used when running this file directly, when
  # running through "test.sh" it must be provided using the "--suite" option.
  tinitialize "Docker-Kong test suite" "${BASH_SOURCE[0]}"

  tchapter "ownership is root:kong"


  for filename in \
    /usr/local/share/lua/5.1/ \
    /usr/local/share/lua/5.1/kong/plugins/ \
    /usr/local/lib/lua/5.1/ \
    /usr/local/lib/luarocks/rocks-5.1/
  do
    ttest "owenership $filename"
    local USR
    local GRP
    USR=$(docker run -ti --rm "kong-$BASE" ls -ld $filename | awk '{print $3}')
    GRP=$(docker run -ti --rm "kong-$BASE" ls -ld $filename | awk '{print $4}')
    if [ "$USR:$GRP" == "root:kong" ]; then
      tsuccess
    else
      tmessage "user and group set to $USR:$GRP"
      tfailure
    fi
  done

  tfinish
}

# No need to modify anything below this comment

# shellcheck disable=SC1090  # do not follow source
[[ "$T_PROJECT_NAME" == "" ]] && set -e && if [[ -f "${1:-$(dirname "$(realpath "$0")")/test.sh}" ]]; then source "${1:-$(dirname "$(realpath "$0")")/test.sh}"; else source "${1:-$(dirname "$(realpath "$0")")/run.sh}"; fi && set +e
run_test
