#!/usr/bin/env bash
set -e

gawk --version &> /dev/null || {
  echo "gawk is required to run this script."
  exit 1
}

mode=
version=
force=

function usage() {
  echo "usage: $0 <-p|-m> <version>"
  echo "   -p for patch release (x.y.Z)"
  echo "   -m for minor release (x.Y.0)"
  echo "   -r for release candidate (x.Y.0rcZ)"
  echo "example: $0 -p 1.1.2"
}

while [ "$1" ]
do
  case "$1" in
  --help)
    usage
    exit 0
    ;;
  -p)
    mode=patch
    ;;
  -r)
    mode=rc
    ;;
  -m)
    mode=minor
    ;;
  -f)
    force=yes
    ;;
  [0-9]*)
    version=$1
    ;;
  esac
  shift
done

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

if [ "$mode" = "" ]
then
  die "Error: mode flag is mandatory"
fi

if ! [ "$version" ]
then
  die "Error: missing version"
fi

git checkout master
git pull

if ! grep -q "$version" Dockerfile.apk
then
  if [[ "$force" = "yes" ]]
  then
    echo "Forcing to use the tag even though it is not in master."

    git checkout "$version"

    if ! grep -q "$version$" Dockerfile.apk
    then
      die "Error: version in build script doesn't match required version."
    fi
  else
    echo "****************************************"
    echo "Error: this script should be run only after the"
    echo "desired release is merged in master of docker-kong."
    echo ""
    echo "For making releases based on old versions,"
    echo "Use -f to override and submit from the tag anyway."
    echo "****************************************"
    die "Failed."
  fi
fi

xy=${version%.*}
z=${version#$xy.}

rc=0
if [ "$mode" = "rc" ]
then
  rc=${version#*rc}
  z=${z%rc*}
fi

commit=$(git show "$version" | grep "^commit" | head -n 1 | cut -b8-48)

if [ "$mode" = "patch" ]
then
  prev="$xy.$[z-1]"
  prevcommit=$(git show "$prev" | grep "^commit" | head -n 1 | cut -b8-48)
elif [ "$mode" = "rc" -a "$rc" -gt 1 ]
then
  prev="$xy.${z}rc$[rc-1]"
  prevcommit=$(git show "$prev" | grep "^commit" | head -n 1 | cut -b8-48)
fi

rm -rf submit
mkdir submit
cd submit
git clone https://github.com/kong/official-images
cd official-images
git remote add upstream http://github.com/docker-library/official-images
git fetch upstream
git checkout master
git merge upstream/master

git checkout -b release/$version

if [ "$mode" = "patch" ]
then
  sed "s|$prev-alpine|$version-alpine|;
       s|$prev-ubuntu|$version-ubuntu|;
       s|$prev,|$version,|;
       s|$prevcommit|$commit|;
       s|refs/tags/$prev|refs/tags/$version|" library/kong > library/kong.new
  mv library/kong.new library/kong

elif [ "$mode" = "rc" -a "$rc" -gt 1 ]
then
  sed "s|$prev-alpine|$version-alpine|;
       s|$prev-ubuntu|$version-ubuntu|;
       s|, ${xy}rc$[rc-1]|, ${xy}rc${rc}|;
       s|$prev,|$version,|;
       s|$prevcommit|$commit|;
       s|refs/tags/$prev|refs/tags/$version|" library/kong > library/kong.new
  mv library/kong.new library/kong

elif [ "$mode" = "rc" -a "$rc" -eq 1 ]
then
  gawk '
    BEGIN {
      reset = 0
      not_yet_first = 1
    }
    /^Tags/ {
      if (not_yet_first == 1) {
        not_yet_first = 0
        before_first = 1
      }
    }
    {
      if (before_first == 1) {
        v = "'$version'"
        xy = "'$xy'"
        commit = "'$commit'"
        print "Tags: " v "-alpine, " v ", " xy ", alpine"
        print "GitCommit: " commit
        print "GitFetch: refs/tags/" v
        print "Directory: alpine"
        print "Architectures: amd64"
        print ""
        print "Tags: " v "-ubuntu"
        print "GitCommit: " commit
        print "GitFetch: refs/tags/" v
        print "Directory: ubuntu"
        print "Architectures: amd64, arm64v8"
        print ""
        before_first = 0
      } else {
        print
      }
    }
  ' library/kong > library/kong.new
  mv library/kong.new library/kong

elif [ "$mode" = "minor" ]
then
  gawk '
    BEGIN {
      reset = 0
      not_yet_first = 1
    }
    /^Tags/ {
      if (not_yet_first == 1) {
        not_yet_first = 0
        before_first = 1
      }
    }
    /Tags: .*[0-9]rc[0-9].*/ {
      in_rc_tag = 1
    }
    /^ *$/ {
      if (in_rc_tag == 1) {
        reset = 1
      }
    }
    {
      if (before_first == 1) {
        v = "'$version'"
        xy = "'$xy'"
        commit = "'$commit'"
        print "Tags: " v "-alpine, " v ", " xy ", alpine, latest"
        print "GitCommit: " commit
        print "GitFetch: refs/tags/" v
        print "Directory: alpine"
        print "Architectures: amd64, arm64v8"
        print ""
        print "Tags: " v "-ubuntu, " xy "-ubuntu, ubuntu"
        print "GitCommit: " commit
        print "GitFetch: refs/tags/" v
        print "Directory: ubuntu"
        print "Architectures: amd64, arm64v8"
        print ""
        before_first = 0
      }
      if (!(in_rc_tag == 1)) {
        gsub(", latest", "")
        gsub(", alpine", "")
        gsub(", ubuntu", "")
        print
      }
      if (reset == 1) {
        in_rc_tag = 0
        reset = 0
      }
    }
  ' library/kong > library/kong.new
  mv library/kong.new library/kong
fi

echo "****************************************"
git diff
echo "****************************************"

echo "Everything looks all right? (y/n)"
echo "(Answering y will commit, push the branch, and submit the PR)"
read
if ! [ "$REPLY" == "y" ]
then
  exit 1
fi

git commit -av -m "kong $version"
git push --set-upstream origin release/$version

hub pull-request -b docker-library:master -h "release/$version" -m "bump Kong to $version"
