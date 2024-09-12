#!/usr/bin/env bash

source test/util.sh
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/../openresty-build-tools/common.sh

DOCKER_BUILD_ARGS=()

KONG_TEST_IMAGE_NAME=$DOCKER_RELEASE_REPOSITORY:$ARCHITECTURE-$KONG_TEST_CONTAINER_TAG

image_id=$(docker image inspect -f '{{.ID}}' "$KONG_TEST_IMAGE_NAME" || true)
if [ -n "$image_id" ]; then
  msg_test "Tests image Name: $KONG_TEST_IMAGE_NAME"
  msg_test "Tests image ID: $image_id"
  exit 0;
fi

rm -rf docker-kong || true
git clone --single-branch --branch $DOCKER_KONG_VERSION https://github.com/Kong/docker-kong.git docker-kong
chmod -R 755 docker-kong/*.sh

if [ "$RESTY_IMAGE_BASE" == "src" ]; then
  exit 0
elif [ "$RESTY_IMAGE_BASE" == "alpine" ]; then
  cp output/${KONG_PACKAGE_NAME}-${KONG_RELEASE_LABEL}.${ARCHITECTURE}.apk.tar.gz docker-kong/kong.apk.tar.gz
elif [ "$PACKAGE_TYPE" == "deb" ]; then
  cp output/*${ARCHITECTURE}*.deb docker-kong/kong.deb
else
  cp output/*.${PACKAGE_TYPE} docker-kong/kong.${PACKAGE_TYPE}
fi

pushd ./docker-kong
  if \
    [ "$RESTY_IMAGE_BASE" == 'rhel' ] || \
    [[ "$RESTY_IMAGE_BASE" == *'/ubi'* ]] || \
    [[ "$RESTY_IMAGE_BASE" == *'redhat'* ]]
  then
    major="${RESTY_IMAGE_TAG%%.*}"

    sed -i.bak "s|^FROM .*|FROM registry.access.redhat.com/ubi${major}|" Dockerfile.$PACKAGE_TYPE
  elif [ "$RESTY_IMAGE_BASE" == "debian" ]; then
    sed -i.bak 's/^FROM .*/FROM '${RESTY_IMAGE_BASE}:${RESTY_IMAGE_TAG}-slim'/' Dockerfile.$PACKAGE_TYPE
  else
    sed -i.bak 's/^FROM .*/FROM '${RESTY_IMAGE_BASE}:${RESTY_IMAGE_TAG}'/' Dockerfile.$PACKAGE_TYPE
  fi

  if [ -n "$DOCKER_LABEL_REVISION" ]; then
    DOCKER_BUILD_ARGS+=(--label "org.opencontainers.image.revision=$DOCKER_LABEL_REVISION")
  fi

  DOCKER_BUILD_ARGS+=(--platform linux/${ARCHITECTURE})
  DOCKER_BUILD_ARGS+=(--no-cache)
  DOCKER_BUILD_ARGS+=(--pull)
  DOCKER_BUILD_ARGS+=(--build-arg ASSET=local .)

  if [[ "$EDITION" == 'enterprise' ]]; then
    DOCKER_BUILD_ARGS+=(--build-arg EE_PORTS="8002 8445 8003 8446 8004 8447")
  fi
  
  with_backoff docker build \
    --progress=${DOCKER_BUILD_PROGRESS:-auto} \
    -t $KONG_TEST_IMAGE_NAME \
    -f Dockerfile.$PACKAGE_TYPE \
    ${DOCKER_LABELS} \
    "${DOCKER_BUILD_ARGS[@]}"

  msg_test "Tests image Name: $KONG_TEST_IMAGE_NAME"
popd

rm -rf docker-kong || true
