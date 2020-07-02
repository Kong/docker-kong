#!/usr/bin/env bash

set -o errexit


function die {
  >&2 echo "$@"
  exit 1
}

function usage {
  cat << EOF
Build Kong EE Docker images and upload to our Bintray registry.

WARNING: This script is intended to be used ONLY for Enterprise
releases.

usage: $0 options
 -e Kong Enterprise
 -v Kong EE version to target (REQUIRED)
 -u Bintray username (REQUIRED)
 -k Bintray API key  (REQUIRED)
 -o Bintray organization
 -r Bintray Docker registry address
 -i Build internal preview
 -p Platform to build for
 -b Build only
 -P Push only
 -l Create 'latest' tag - which is a link to alpine distro
 -a Disable anonymous reports (a stands for anonymous)
 -h Print this help message
 -f use file instead of downloading from Bintray
 -R Release type
EOF
  exit 1
}

if ! hash python &> /dev/null; then
  echo "Python is required, please install it."
  exit 1
fi

BINTRAY_ORG="kong"
BINTRAY_USR=
BINTRAY_KEY=
PLATFORMS=all

NO_PHONE_HOME=
NO_PHONE_HOME_NAME=reports-off

KONG_EDITION="community-edition"

EE_PORTS="8002 8445 8003 8446 8004 8447"

while getopts "f:R:v:u:k:o:r:bPp:hliea" option; do
  case $option in
    f)
      KONG_FILE=$OPTARG
      ;;
    v)
      KONG_VERSION=$OPTARG
      ;;
    u)
      BINTRAY_USR=$OPTARG
      ;;
    k)
      BINTRAY_KEY=$OPTARG
      ;;
    o)
      BINTRAY_ORG=$OPTARG
      ;;
    r)
      BINTRAY_REGISTRY_URL=$OPTARG
      ;;
    R)
      KONG_RELEASE=$OPTARG
      ;;
    e)
      KONG_ENTERPRISE=true
      KONG_EDITION="enterprise-edition"
      ;;
    i)
      INTERNAL_PREVIEW=true
      ;;
    l)
      TAG_LATEST=true
      ;;
    b)
      BUILD_ONLY=true
      ;;
    P)
      PUSH_ONLY=true
      ;;
    p)
      PLATFORMS=$OPTARG
      ;;
    h)
      usage
      ;;
    a)
      NO_PHONE_HOME=1
      ;;
  esac
done


[[ "$KONG_EDITION" == "enterprise-edition" ]] ||
  die "This script is intended to be used ONLY for Enterprise releases."

if [[ "$KONG_RELEASE" == rc* ]] ; then
    KONG_RC=$KONG_RELEASE
fi

if [[ "$KONG_RELEASE" == "internal-preview" ]] ; then
    INTERNAL_PREVIEW=true
fi

[[ -z $KONG_VERSION ]] && usage

[[ ! -z $KONG_FILE && -z $BUILD_ONLY ]] && die "-f must be used with -b"

if [[ -z $BINTRAY_USR ]] || [[ -z $BINTRAY_KEY ]] && [[ -z $KONG_FILE ]]; then
  usage
fi

if { [[ -n $INTERNAL_PREVIEW ]] || [[ -n $KONG_RC ]] ;} && [[ -n $NO_PHONE_HOME ]]; then
  echo "We do not build nor push internal preview images or rcs without phone home"
  echo "Doing nothing --> No error, keep jenkins happy"
  exit 0
fi

BINTRAY_REGISTRY_URL="kong-docker-kong-enterprise-edition-docker.bintray.io"

if [[ -n $INTERNAL_PREVIEW ]]; then
  BINTRAY_REGISTRY_URL="kong-docker-kong-community-edition-internal-preview-docker.bintray.io"
  if [[ -n $KONG_ENTERPRISE ]]; then
    BINTRAY_REGISTRY_URL="kong-docker-kong-enterprise-edition-internal-preview-docker.bintray.io"
  fi

  BINTRAY_INTERNAL_PACKAGE_REPO="kong-community-edition-internal-preview"
  if [[ -n $KONG_ENTERPRISE ]]; then
    BINTRAY_INTERNAL_PACKAGE_REPO="kong-enterprise-edition-internal-preview"
  fi
fi


if [[ -n $KONG_RC ]]; then
    if [[ -n $KONG_ENTERPRISE ]]; then
        BINTRAY_REGISTRY_URL="kong-docker-kong-enterprise-edition-rc-docker.bintray.io"
    fi

    BINTRAY_INTERNAL_PACKAGE_REPO="kong-community-edition-rc"
    if [[ -n $KONG_ENTERPRISE ]]; then
        BINTRAY_INTERNAL_PACKAGE_REPO="kong-enterprise-edition-rc"
    fi
fi

supported_platforms=(alpine centos rhel)
platforms_to_build=()

for platform in "$PLATFORMS"; do
  if [[ "all" == "$platform" ]]; then
    platforms_to_build=("${supported_platforms[@]}")
  elif ! [[ ${supported_platforms[*]} = *$platform* ]]; then
    echo "Supported platforms:"
    IFS=$'\n'; echo -e "${supported_platforms[*]}"
    echo "all - to build all for platforms"
    exit 1
  else
    platforms_to_build+=($platform)
  fi
done

function build_no_phone_home {
  local platform=$1

  pushd phone-home-off > /dev/null
    docker build --build-arg EE_PORTS="$EE_PORTS" --build-arg KONG_VERSION=$KONG_VERSION --build-arg BASE_IMAGE=kong-$KONG_EDITION:$platform-$KONG_VERSION \
      -t kong-$KONG_EDITION:$platform-$NO_PHONE_HOME_NAME-$KONG_VERSION .
  popd > /dev/null
}

function build_alpine_image {
  local alpine_url
  if [[ -z $KONG_FILE ]]; then
    alpine_url=$(curl -u $BINTRAY_USR:$BINTRAY_KEY -s -XPOST \
                            "https://bintray.com/api/v1/signed_url/kong/${BINTRAY_INTERNAL_PACKAGE_REPO:=kong-$KONG_EDITION-alpine-tar}/kong-$KONG_EDITION-$KONG_VERSION${INTERNAL_PREVIEW:+-internal-preview}${KONG_RC:+-$KONG_RC}.apk.tar.gz" \
                            -H "Content-Type: application/json" -d '{"valid_for_secs": 300}' \
                         | python -c "import sys, json; print(json.load(sys.stdin)['url'])")
    echo $alpine_url
    curl -o alpine/kong.tar.gz -L "${alpine_url}"
  else
    cp $KONG_FILE alpine/kong.tar.gz
  fi

  echo "Building Kong ($KONG_EDITION) Alpine image..."
  pushd alpine > /dev/null
   docker build --build-arg EE_PORTS="$EE_PORTS" --build-arg KONG_VERSION=$KONG_VERSION \
      -t kong-$KONG_EDITION:alpine-$KONG_VERSION .
  popd > /dev/null

  echo "Kong EE Alpine image built successfully"

  if [[ -n $NO_PHONE_HOME ]]; then
    build_no_phone_home alpine
  fi
}

function build_centos_image {
  if [[ -z $KONG_FILE ]]; then
    local centos_url=$(curl -u $BINTRAY_USR:$BINTRAY_KEY -s -XPOST \
                            "https://bintray.com/api/v1/signed_url/kong/${BINTRAY_INTERNAL_PACKAGE_REPO:=kong-$KONG_EDITION-rpm/centos/7}/kong-$KONG_EDITION-$KONG_VERSION${INTERNAL_PREVIEW:+-internal-preview}${KONG_RC:+-$KONG_RC}.el7.noarch.rpm" \
                            -H "Content-Type: application/json" -d '{"valid_for_secs": 300}' \
                         | python -c "import sys, json; print(json.load(sys.stdin)['url'])")
    echo $centos_url
    curl -o centos/kong.rpm -L "${centos_url}"
  else
    cp $KONG_FILE alpine/kong.rpm
  fi

  echo "Building Kong ($KONG_EDITION) CentOS image..."
  pushd centos > /dev/null
    docker build --build-arg EE_PORTS="$EE_PORTS" --build-arg KONG_VERSION=$KONG_VERSION \
      -t kong-$KONG_EDITION:centos-$KONG_VERSION .
  popd > /dev/null

  echo "Kong EE CentOS image built successfully"

  if [[ -n $NO_PHONE_HOME ]]; then
    build_no_phone_home centos
  fi
}

function build_rhel_image {
  if [[ -z $KONG_FILE ]]; then
    local rhel_url=$(curl -u $BINTRAY_USR:$BINTRAY_KEY -s -XPOST \
                          "https://bintray.com/api/v1/signed_url/kong/${BINTRAY_INTERNAL_PACKAGE_REPO:=kong-$KONG_EDITION-rpm/rhel/7}/kong-$KONG_EDITION-$KONG_VERSION${INTERNAL_PREVIEW:+-internal-preview}${KONG_RC:+-$KONG_RC}.rhel7.noarch.rpm" \
                          -H "Content-Type: application/json" -d '{"valid_for_secs": 300}' \
                       | python -c "import sys, json; print(json.load(sys.stdin)['url'])")

    echo $rhel_url
    curl -o rhel/kong.rpm -L "${rhel_url}"
  else
    cp $KONG_FILE alpine/kong.rpm
  fi

  echo "Building Kong ($KONG_EDITION) RHEL image..."
  pushd rhel > /dev/null
    docker build --build-arg EE_PORTS="$EE_PORTS" --build-arg KONG_VERSION=$KONG_VERSION \
      -t kong-$KONG_EDITION:rhel-$KONG_VERSION .
  popd > /dev/null

  echo "Kong EE RHEL image built successfully"

  if [[ -n $NO_PHONE_HOME ]]; then
    build_no_phone_home rhel
  fi
}

function push_alpine_image {
  local local_tag="kong-$KONG_EDITION:alpine-$KONG_VERSION"
  if [[ -n $NO_PHONE_HOME ]]; then
    BINTRAY_REGISTRY_URL="kong-docker-kong-enterprise-edition-$NO_PHONE_HOME_NAME-docker.bintray.io"
    local_tag="kong-$KONG_EDITION:alpine-$NO_PHONE_HOME_NAME-$KONG_VERSION"
  fi

  docker login -u $BINTRAY_USR -p $BINTRAY_KEY \
    $BINTRAY_REGISTRY_URL

  echo "Pushing Kong ($KONG_EDITION) Alpine Docker image..."

  # tag image accordingly
  docker tag $local_tag \
    $BINTRAY_REGISTRY_URL/kong-$KONG_EDITION:$KONG_VERSION-alpine

  # push image to our registry
  docker push $BINTRAY_REGISTRY_URL/kong-$KONG_EDITION:$KONG_VERSION-alpine

  # update latest tag
  if [[ -n $TAG_LATEST ]]; then
    docker tag $BINTRAY_REGISTRY_URL/kong-$KONG_EDITION:$KONG_VERSION-alpine \
      $BINTRAY_REGISTRY_URL/kong-$KONG_EDITION:latest
    docker push $BINTRAY_REGISTRY_URL/kong-$KONG_EDITION:latest
  fi

  docker logout $BINTRAY_REGISTRY_URL
}

function push_centos_image {
  local local_tag="kong-$KONG_EDITION:centos-$KONG_VERSION"
  if [[ -n $NO_PHONE_HOME ]]; then
    BINTRAY_REGISTRY_URL="kong-docker-kong-enterprise-edition-$NO_PHONE_HOME_NAME-docker.bintray.io"
    local_tag="kong-$KONG_EDITION:centos-$NO_PHONE_HOME_NAME-$KONG_VERSION"
  fi

  docker login -u $BINTRAY_USR -p $BINTRAY_KEY \
    $BINTRAY_REGISTRY_URL

  echo "Pushing Kong ($KONG_EDITION) CentOS Docker image..."

  # tag image accordingly
  docker tag $local_tag \
    $BINTRAY_REGISTRY_URL/kong-$KONG_EDITION:$KONG_VERSION-centos

  # push image to our registry
  docker push $BINTRAY_REGISTRY_URL/kong-$KONG_EDITION:$KONG_VERSION-centos

  docker logout $BINTRAY_REGISTRY_URL

}

function push_rhel_image {
  local local_tag="kong-$KONG_EDITION:rhel-$KONG_VERSION"
  if [[ -n $NO_PHONE_HOME ]]; then
    BINTRAY_REGISTRY_URL="kong-docker-kong-enterprise-edition-$NO_PHONE_HOME_NAME-docker.bintray.io"
    local_tag="kong-$KONG_EDITION:rhel-$NO_PHONE_HOME_NAME-$KONG_VERSION"
  fi

  docker login -u $BINTRAY_USR -p $BINTRAY_KEY \
    $BINTRAY_REGISTRY_URL

  echo "Pushing Kong EE RHEL Docker image..."

  # tag image accordingly
  docker tag $local_tag \
    $BINTRAY_REGISTRY_URL/kong-$KONG_EDITION:$KONG_VERSION-rhel

  # push image to our registry
  docker push $BINTRAY_REGISTRY_URL/kong-$KONG_EDITION:$KONG_VERSION-rhel

  docker logout $BINTRAY_REGISTRY_URL

}

# Do the build/push process for each selected platform
platform=${platforms_to_build[0]}

case $platform in
  alpine)
    if [[ -z $PUSH_ONLY ]]; then
      build_alpine_image
    fi
    if [[ -z $BUILD_ONLY ]]; then
      if [[ -z $(docker images --format "{{.Repository}}" \
                        kong-$KONG_EDITION:alpine-$KONG_VERSION) ]]; then
        echo "Alpine image not found; build it first!"
        continue
      fi
      push_alpine_image
    fi
    ;;
  centos)
    if [[ -z $PUSH_ONLY ]]; then
      build_centos_image
    fi
    if [[ -z $BUILD_ONLY ]]; then
      if [[ -z $(docker images --format "{{.Repository}}" \
                        kong-$KONG_EDITION:centos-$KONG_VERSION) ]]; then
        echo "CentOS image not found; build it first!"
        continue
      fi
      push_centos_image
    fi
    ;;
  rhel)
    if [[ -z $PUSH_ONLY ]]; then
      build_rhel_image
    fi
    if [[ -z $BUILD_ONLY ]]; then
      if [[ -z $(docker images --format "{{.Repository}}" \
                        kong-enterprise-edition:rhel-$KONG_VERSION) ]]; then
        echo "RHEL image not found; build it first!"
        continue
      fi
      push_rhel_image
    fi
    ;;
esac
