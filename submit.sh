#!/usr/bin/env bash
set -e

mode=
version=
force=

while [ "$1" ]
do
   case "$1" in
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

function usage() {
   echo "usage: $0 <-p|-m> <version>"
   echo "   -p for patch release (x.y.Z)"
   echo "   -m for minor release (x.Y.0)"
   echo "   -r for release candidate (x.Y.0rcZ)"
   echo "example: $0 -p 1.1.2"
}

if [ "$mode" = "" ]
then
   echo "Error: mode flag is mandatory"
   echo
   usage
   exit 1
fi

if ! [ "$version" ]
then
   echo "Error: missing version"
   usage
   exit 1
fi

git checkout master
git pull

if ! grep -q "ENV KONG_VERSION $version$" alpine/Dockerfile
then
   if [[ "$force" = "yes" ]]
   then
      echo "Forcing to use the tag even though it is not in master."

      git checkout "$version"

      if ! grep -q "ENV KONG_VERSION $version$" alpine/Dockerfile
      then
         echo "****************************************"
         echo "Error: version in Dockerfile doesn't match required version."
         echo "****************************************"
         exit 1
      fi
   else
      echo "****************************************"
      echo "Error: this script should be run only after the"
      echo "desired release is merged in master of docker-kong."
      echo ""
      echo "For making releases based on old versions,"
      echo "Use -f to override and submit from the tag anyway."
      echo "****************************************"
      exit 1
   fi
fi

xy=${version%.*}
z=${version#$xy.}

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
        s|$prev-centos|$version-centos|;
        s|$prev,|$version,|;
        s|$prevcommit|$commit|;
        s|refs/tags/$prev|refs/tags/$version|" library/kong > library/kong.new
   mv library/kong.new library/kong

elif [ "$mode" = "rc" -a "$rc" -gt 1 ]
then
   sed "s|$prev-alpine|$version-alpine|;
        s|$prev-centos|$version-centos|;
        s|, ${xy}rc$[rc-1]|, ${xy}rc${rc}|;
        s|$prev,|$version,|;
        s|$prevcommit|$commit|;
        s|refs/tags/$prev|refs/tags/$version|" library/kong > library/kong.new
   mv library/kong.new library/kong

elif [ "$mode" = "rc" -a "$rc" -eq 1 ]
then
   echo "****************************************"
   echo "Error: rc1 automation is not implemented yet."
   echo "****************************************"
   exit 1

elif [ "$mode" = "minor" ]
then
   echo "****************************************"
   echo "Error: minor release update automation is not implemented yet."
   echo "****************************************"
   exit 1
fi

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

git commit -av -m "kong $version"
git push --set-upstream origin release/$version

pr="https://github.com/Kong/official-images/pull/new/release/$version"

( open "$pr" || xdg-open "$pr" || firefox "$pr" ) &
