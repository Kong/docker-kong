#!/usr/bin/env bash
set -e

if ! [ "$1" ]
then
   echo "usage: $0 <version>"
   echo "example: $0 1.2.3"
   exit 1
fi

version=$1

if [[ "$version" =~ "rc" ]]; then
  version="${version//-}"
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

# get digest of a docker image
function update_docker_image_sha() {
   docker_file=$1
   tag=$2
   docker pull -q "$tag"
   # outputs kong/kong:3.3.0-ubuntu@sha256:b476a8eacb0025fea9b7d3220990eb9b785c2ff24ef5f84f8bb2c0fbcb17254d
   tag_with_sha256=$(docker inspect --format='{{index .RepoTags 0}}@sha256:{{ index (split (index .RepoDigests 0) ":" ) 1}}' "$tag")

   sed -i -e "s!FROM .*!FROM $tag_with_sha256!" "$docker_file"
}


hub --version &> /dev/null || die "hub is not in PATH. Get it from https://github.com/github/hub"

update_docker_image_sha Dockerfile.deb kong/kong:$version-ubuntu
update_docker_image_sha Dockerfile.apk kong/kong:$version-alpine


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
