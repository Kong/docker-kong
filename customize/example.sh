#!/usr/bin/env bash

# pick a plugin repo, and pack the rock, and its dependencies (clear first)
# because we use a local LuaRocks repo, we also need the dependencies in there
# since the public one will not be available
pushd ~/code/kong-plugin-enterprise-request-validator
luarocks remove kong-plugin-request-validator --force
luarocks remove net-url --force
luarocks remove lua-resty-ljsonschema --force
luarocks make
luarocks pack kong-plugin-request-validator
luarocks pack net-url
luarocks pack lua-resty-ljsonschema
popd

# create a LuaRocks repo, and copy the rocks in there. This directory will be
# used as the base LuaRocks server we're installing from. These, and only these,
# rocks can be installed.
rm -rf ./rocksdir
mkdir ./rocksdir
mv ~/code/kong-plugin-enterprise-request-validator/*.rock ./rocksdir/

#build the custom image
docker build \
   --build-arg "KONG_LICENSE_DATA=$KONG_LICENSE_DATA" \
   --build-arg KONG_BASE="kong-ee" \
   --build-arg PLUGINS="kong-plugin-request-validator" \
   --build-arg ROCKS_DIR="./rocksdir" \
   --tag "your_new_image" .


