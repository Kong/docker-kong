#!/usr/bin/env bash
set -e

if ! [ "$1" ]
then
   echo "usage: $0 <version>"
   echo "example: $0 1.2.3"
   exit 1
fi

version=$1

function red() {
   echo -e "\033[1;31m$@\033[0m"
}

function die() {
   red "*** $@"
   echo "See also: $0 --help"
   echo
   exit 1
}

hub --version &> /dev/null || die "hub is not in PATH. Get it from https://github.com/github/hub"

pushd alpine
   url=$(grep bintray.com Dockerfile | awk -F" " '{print $3}' | sed 's/\"//g' | sed 's/$KONG_VERSION/'$version'/g')
   curl -fL $url -o /tmp/kong
   new_sha=$(sha256sum /tmp/kong | cut -b1-64)
   
   sed -i -e 's/ARG KONG_SHA256=.*/ARG KONG_SHA256=\"'$new_sha'\"/g' Dockerfile
   sed -i -e 's/ARG KONG_VERSION=.*/ARG KONG_VERSION='$version'/g' Dockerfile
popd

pushd centos
   url=$(grep bintray.com Dockerfile | awk -F" " '{print $3}' | sed 's/\"//g' | sed 's/$KONG_VERSION/'$version'/g')
   curl -fL $url -o /tmp/kong
   new_sha=$(sha256sum /tmp/kong | cut -b1-64)
   
   sed -i -e 's/ARG KONG_SHA256=.*/ARG KONG_SHA256=\"'$new_sha'\"/g' Dockerfile
   sed -i -e 's/ARG KONG_VERSION=.*/ARG KONG_VERSION='$version'/g' Dockerfile
popd

pushd rhel
   url=$(grep bintray.com Dockerfile | awk -F" " '{print $3}' | sed 's/\"//g' | sed 's/$KONG_VERSION/'$version'/g')
   curl -fL $url -o /tmp/kong
   new_sha=$(sha256sum /tmp/kong | cut -b1-64)
   
   sed -i -e 's/ARG KONG_SHA256=.*/ARG KONG_SHA256=\"'$new_sha'\"/g' Dockerfile
   sed -i -e 's/ARG KONG_VERSION=.*/ARG KONG_VERSION='$version'/g' Dockerfile
popd

pushd ubuntu
   sed -i -e 's/ARG KONG_VERSION=.*/ARG KONG_VERSION='$version'/g' Dockerfile
popd

echo "****************************************"
git diff
echo "****************************************"

echo "Everything looks all right? (y/n)"
echo "(Answering y will commit, push the branch, and open a browser with the PR)"
read
if ! [ "$REPLY" == "y" ]
then
   exit 1
fi

git commit -av -m "chore(*) bump to Kong $version"
git push --set-upstream origin release/$version

hub pull-request -b master -h "$branch" -m "Release: $version"
