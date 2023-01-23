ARG KONG_BASE=kong:latest

FROM ${KONG_BASE} AS build

ARG PLUGINS
ENV INJECTED_PLUGINS=${PLUGINS}

ARG TEMPLATE=empty_file
ENV TEMPLATE=${TEMPLATE}

ARG ROCKS_DIR=empty_file
ENV ROCKS_DIR=${ROCKS_DIR}

ARG KONG_LICENSE_DATA
ENV KONG_LICENSE_DATA=${KONG_LICENSE_DATA}

COPY $TEMPLATE /custom_nginx.conf
COPY $ROCKS_DIR /rocks-server
COPY packer.lua /packer.lua

USER root

RUN /usr/local/openresty/luajit/bin/luajit /packer.lua -- "$INJECTED_PLUGINS"

FROM ${KONG_BASE}

USER root

# Workarounds used:
#  1 - the "custom_nginx.conf*" wildcard ensures it doesn't fail if it doesn't exist
#  2 - "RUN true", see https://stackoverflow.com/questions/51115856/docker-failed-to-export-image-failed-to-create-image-failed-to-get-layer/62409523#62409523

# replace the entrypoint, add the custom template if it exists
COPY --from=build /docker-entrypoint.sh /old-entrypoint.sh /custom_nginx.conf* /
RUN true

# add the Lua files (.lua)
COPY --from=build /usr/local/share/lua/5.1 /usr/local/share/lua/5.1
RUN true

# add the compiled libraries (.so)
COPY --from=build /usr/local/lib/lua/5.1 /usr/local/lib/lua/5.1
RUN true

# add the Luarocks manifest
COPY --from=build /usr/local/lib/luarocks/rocks-5.1 /usr/local/lib/luarocks/rocks-5.1
RUN true

# add any Lua commandline scripts
# TODO: should commandline scripts be copied at all?
#COPY --from=build /usr/local/bin /usr/local/bin


HEALTHCHECK --interval=60s --timeout=10s --retries=10 CMD kong-health

USER kong
