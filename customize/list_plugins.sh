#!/usr/bin/env bash

KONG_IMAGE=$1
if [ "$1" == "" ]; then
    KONG_IMAGE="kong:latest"
    >&2 echo "No image passed on command-line, defaulting to \"$KONG_IMAGE\""
fi
>&2 echo "Listing plugins for Kong image \"$KONG_IMAGE\""

# start a local Kong
CID=$(docker run -it --rm -d \
        -e KONG_DATABASE=off \
        -e KONG_LICENSE_DATA \
        -e KONG_ADMIN_LISTEN=0.0.0.0:8001 \
        -p 8001:8001 \
        $KONG_IMAGE kong start)
>&2 echo "Started introspection container id \"$CID\""

# wait for instance to be available and responding
x=1
PLUGIN_DATA=$(curl -s http://localhost:8001/)
while [ ! $? -eq 0 ]; do
    sleep 0.1
    x=$(( x + 1 ))

    if [ $x -gt 50 ]; then
        >&2 echo "ERROR timeout while waiting for Kong instance to become available"
        docker kill "$CID" > /dev/null
        >&2 echo "Destroyed introspection container id \"$CID\""
        exit 1
    fi

    PLUGIN_DATA=$(curl -s http://localhost:8001/)
done

# kill the local Kong instance
docker kill "$CID" > /dev/null
>&2 echo "Destroyed introspection container id \"$CID\""

# send plugin data to stdout
echo "$PLUGIN_DATA" | jq .plugins.available_on_server
