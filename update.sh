#!/usr/bin/env bash
set -e

if ! [ "$1" ]
then
   echo "usage: $0 <version>"
   echo "example: $0 1.1.2"
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

git stash
git checkout master
git checkout -B release/$version

sed "s,ENV KONG_VERSION .*,ENV KONG_VERSION $version," centos/Dockerfile > centos/Dockerfile.new
mv centos/Dockerfile.new centos/Dockerfile

sed "s,ENV KONG_VERSION .*,ENV KONG_VERSION $version," rhel/Dockerfile > rhel/Dockerfile.new
mv rhel/Dockerfile.new rhel/Dockerfile

sed "s,ENV KONG_VERSION .*,ENV KONG_VERSION $version," alpine/Dockerfile > alpine/Dockerfile.new
mv alpine/Dockerfile.new alpine/Dockerfile

sed "s,ENV KONG_VERSION .*,ENV KONG_VERSION $version," ubuntu/Dockerfile > ubuntu/Dockerfile.new
mv ubuntu/Dockerfile.new ubuntu/Dockerfile

apk="kong-$version.amd64.apk.tar.gz"

curl -f -L -o "$apk" "https://bintray.com/kong/kong-alpine-tar/download_file?file_path=$apk" || {
   rm -f "$apk"
   echo "****************************************"
   echo "Failed to download Alpine package."
   echo "Are the release artifact successfully deployed in Bintray?"
   echo "If so, did their URL change? (update the Dockerfiles then!)"
   echo "****************************************"
   exit 1
}

alpinesha=$(sha256sum "$apk" | cut -b1-64)

sed "s,ENV KONG_SHA256 .*,ENV KONG_SHA256 $alpinesha," alpine/Dockerfile > alpine/Dockerfile.new
mv alpine/Dockerfile.new alpine/Dockerfile

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
