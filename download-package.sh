#!/bin/bash

KONG_VERSION=$1
ID=$(grep '^ID=' /etc/os-release | cut -d = -f 2 | sed -e 's/^"//' -e 's/"$//')
DOWNLOAD_URL="https://download.konghq.com/gateway-${KONG_VERSION%%.*}.x"

if [[ "$ID" == "ubuntu" ]] || [[ "$ID" == "debian" ]]; then
    if ! command -v curl &> /dev/null
    then
        apt-get update
        apt-get install -y curl
    fi
    CODENAME=$(cat /etc/os-release | grep VERSION_CODENAME | cut -d = -f 2)
    DOWNLOAD_URL+="-${ID}-${CODENAME}/pool/all/k/kong/kong_${KONG_VERSION}_amd64.deb"
    echo $DOWNLOAD_URL
    curl -fL $DOWNLOAD_URL -o /tmp/kong.deb
elif [[ "$ID" == "rhel" ]]; then
    VERSION=$(grep '^VERSION_ID' /etc/os-release | cut -d = -f 2 | sed -e 's/^"//' -e 's/"$//' | cut -d . -f 1)
    DOWNLOAD_URL+="-rhel-$VERSION/Packages/k/kong-$KONG_VERSION.rhel$VERSION.amd64.rpm"
    echo $DOWNLOAD_URL
    curl -fL $DOWNLOAD_URL -o /tmp/kong.rpm
elif [[ "$ID" == "centos" ]]; then
    VERSION=$(grep '^VERSION_ID' /etc/os-release | cut -d = -f 2 | sed -e 's/^"//' -e 's/"$//' | cut -d . -f 1)
    DOWNLOAD_URL+="-centos-$VERSION/Packages/k/kong-$KONG_VERSION.el$VERSION.amd64.rpm"
    echo $DOWNLOAD_URL
    curl -fL $DOWNLOAD_URL -o /tmp/kong.rpm
elif [[ "$ID" == "alpine" ]]; then
    DOWNLOAD_URL+="-alpine/kong-$KONG_VERSION.${ARCH}.apk.tar.gz"
    echo $DOWNLOAD_URL
    curl -fL $DOWNLOAD_URL -o /tmp/kong.apk.tar.gz
fi
