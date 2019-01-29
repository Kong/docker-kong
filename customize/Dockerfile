ARG KONG_BASE=kong:latest



FROM ${KONG_BASE} AS build

ARG PLUGINS
ENV INJECTED_PLUGINS=${PLUGINS}
ARG TEMPLATE=empty_file
ENV TEMPLATE=${TEMPLATE}
COPY $TEMPLATE /plugins/custom_nginx.conf
COPY packer.lua /packer.lua
RUN /usr/local/openresty/luajit/bin/luajit /packer.lua -- "$INJECTED_PLUGINS"



FROM ${KONG_BASE}

COPY --from=build /plugins /plugins
RUN /plugins/install_plugins.sh
