#!/usr/bin/env bash
set -ex

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

#git stash
#git checkout "$prev_tag"
#if [ "$prev_tag" = "master" ]
#then
#   git pull
#fi
#git checkout -B release/$version

sed -i -e "s/VERSION='$version'/VERSION='$prev_tag'/" */Dockerfile

pushd alpine
   URL=$(grep "URL='http" Dockerfile | grep -v enterprise | awk -F\' '{ print $2 $3 $4 }' | sed 's/$VERSION/'$prev_tag'/g')
   curl -f -L -o asset.new $URL
   new_sha=$(sha256sum asset.new | cut -b1-64)
   
   URL=$(grep "URL='http" Dockerfile | grep -v enterprise | awk -F\' '{ print $2 $3 $4 }' | sed 's/$VERSION/'$version'/g')
   curl -f -L -o asset.old $URL
   old_sha=$(sha256sum asset.old | cut -b1-64)
   
   sed -i -e 's/'$old_sha'/'$new_sha'/g' Dockerfile
   rm asset.old asset.new
popd

exit 123

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
