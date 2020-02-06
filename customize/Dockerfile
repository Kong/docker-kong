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

COPY $TEMPLATE /plugins/custom_nginx.conf
COPY $ROCKS_DIR /rocks-server
COPY packer.lua /packer.lua

USER root

RUN /usr/local/openresty/luajit/bin/luajit /packer.lua -- "$INJECTED_PLUGINS"


FROM ${KONG_BASE}

COPY --from=build /plugins /plugins

USER root

RUN /plugins/install_plugins.sh

USER kong
