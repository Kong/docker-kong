#!/usr/bin/env bash

function run_test {
  # the suite name below will only be used when rtunning this file directly, when
  # running through "test.sh" it must be provided using the "--suite" option.
  tinitialize "Docker-Kong test suite" "${BASH_SOURCE[0]}"

  tchapter "CIS-Sec tests $KONG_DOCKER_TAG"
  ttest "CIS-Sec for docker-compose"

  pushd compose
    docker-compose stop
    docker-compose up -d
  popd

  until docker-compose ps | grep compose_kong_1 | grep -q "Up"; do sleep 1; done

  rm -rf tests/docker-bench-security

  LOG_OUTPUT=log/docker-bench-security.log

  if [[ "$OSTYPE" == "darwin"* ]]; then
    # The docker-bench-security instructions don't seem to work on MacOS,
    # Despite the README implying that they do.
    # Cloning the repo locally and running the .sh file seems to work.
    # Probably it needs some dev dependencies that my local machine already has

    # Note that the tests assume that your `sed` is GNU-sed instead of the default MacOS'
    # `brew install gnu-sed` + set the PATH as explained in `brew info gnu-sed`

    if ! git clone https://github.com/docker/docker-bench-security.git tests/docker-bench-security; then
      tmessage "Could not clone docker-bench-security"
      tfailure
    else

      pushd tests/docker-bench-security
      if ./docker-bench-security.sh -i kong &&
         [ -f "$LOG_OUTPUT" ]
      then
        tmessage "Could not execute docker-bench-security"
        tfailure
      fi
    fi

  # No MacOS. Assumming Linux
  elif [[ -f /lib/systemd/system/docker.service ]]; then # Ubuntu
    mkdir tests/docker-bench-security
    pushd tests/docker-bench-security
    docker run --rm --net host --pid host --userns host --cap-add audit_control \
      -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
      -v /etc:/etc:ro \
      -v /lib/systemd/system:/lib/systemd/system:ro \
      -v /usr/bin/containerd:/usr/bin/containerd:ro \
      -v /usr/bin/runc:/usr/bin/runc:ro \
      -v /usr/lib/systemd:/usr/lib/systemd:ro \
      -v /var/lib:/var/lib:ro \
      -v /var/run/docker.sock:/var/run/docker.sock:ro \
      --label docker_bench_security \
      docker/docker-bench-security

  else # all other linux distros
    mkdir tests/docker-bench-security
    pushd tests/docker-bench-security
    docker run --rm --net host --pid host --userns host --cap-add audit_control \
      -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
      -v /etc:/etc:ro \
      -v /usr/bin/containerd:/usr/bin/containerd:ro \
      -v /usr/bin/runc:/usr/bin/runc:ro \
      -v /usr/lib/systemd:/usr/lib/systemd:ro \
      -v /var/lib:/var/lib:ro \
      -v /var/run/docker.sock:/var/run/docker.sock:ro \
      --label docker_bench_security \
      docker/docker-bench-security
  fi

  if cat "$LOG_OUTPUT" | grep WARN | grep kong -B 1; then
    tmessage "Found warnings in docker-bench-security report"
    tfailure
  else
    tsuccess
  fi

  popd
  rm -rf tests/docker-bench-security

  tfinish
}

# No need to modify anything below this comment

# shellcheck disable=SC1090  # do not follow source
[[ "$T_PROJECT_NAME" == "" ]] && set -e && source "${1:-$(dirname "$(realpath "$0")")/test.sh}" && set +e
run_test
