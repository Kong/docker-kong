#!/bin/bash

KONG_VERSION="0.11.0"
KONG_SHA256="34cfd44f61a4da5d39ad7b59bad7b4790451065ff8c8c3d000b6258ab6961949"

build_docker_image:
	wget -O kong.tar.gz "https://bintray.com/kong/kong-community-edition-alpine-tar/download_file?file_path=kong-community-edition-${KONG_VERSION}.apk.tar.gz"
	echo "${KONG_SHA256} *kong.tar.gz" | sha256sum -c
	docker build -t kong:"${KONG_VERSION}" .
