#!/usr/bin/env bash
set -e

if ! [ "$1" ]
then
   echo "usage: $0 <version> [<prev_tag>]"
   echo "example: $0 1.2.3 1.2.2"
   exit 1
fi

version=$1
prev_tag=$2

if [ "$prev_tag" = "" ]
then
   prev_tag=master
fi

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
   ./build-ce.sh
   mv /tmp/kong.tar.gz /tmp/kong.tar.gz.old
   old_sha=$(sha256sum /tmp/kong.tar.gz.old | cut -b1-64)
   VERSION=$prev_tag ./build-ce.sh || true
   mv /tmp/kong.tar.gz /tmp/kong.tar.gz.new
   new_sha=$(sha256sum /tmp/kong.tar.gz.new | cut -b1-64)
   
   sed -i -e 's/'$old_sha'/'$new_sha'/g' build-ce.sh
   rm /tmp/kong.tar.gz.*
popd

pushd centos
   ./build-ce.sh
   mv /tmp/kong.rpm /tmp/kong.rpm.old
   old_sha=$(sha256sum /tmp/kong.rpm.old | cut -b1-64)
   VERSION=$prev_tag ./build-ce.sh || true
   mv /tmp/kong.rpm /tmp/kong.rpm.new
   new_sha=$(sha256sum /tmp/kong.rpm.new | cut -b1-64)
   
   sed -i -e 's/'$old_sha'/'$new_sha'/g' build-ce.sh
   rm /tmp/kong.rpm.*
popd

pushd rhel
   ./build-ce.sh
   mv /tmp/kong.rpm /tmp/kong.rpm.old
   old_sha=$(sha256sum /tmp/kong.rpm.old | cut -b1-64)
   VERSION=$prev_tag ./build-ce.sh || true
   mv /tmp/kong.rpm /tmp/kong.rpm.new
   new_sha=$(sha256sum /tmp/kong.rpm.new | cut -b1-64)
   
   sed -i -e 's/'$old_sha'/'$new_sha'/g' build-ce.sh
   rm /tmp/kong.rpm.*
popd

sed -i -e "s/$version/$prev_tag/" */build-ce.sh

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
