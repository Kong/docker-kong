ARG KONG_BASE=kong:latest



FROM ${KONG_BASE} AS build

ARG PLUGINS
ENV INJECTED_PLUGINS=${PLUGINS}

ARG ROCKS_DIR=empty_file
ENV ROCKS_DIR=${ROCKS_DIR}

ARG KONG_LICENSE_DATA
ENV KONG_LICENSE_DATA=${KONG_LICENSE_DATA}

COPY $TEMPLATE /plugins/custom_nginx.conf
COPY $ROCKS_DIR /rocks-server
COPY packer.lua /packer.lua

USER root

RUN /usr/local/openresty/luajit/bin/luajit /packer.lua -- "$INJECTED_PLUGINS" \
    && /plugins/install_plugins.sh


FROM ${KONG_BASE}

COPY --from=build /usr/local /usr/local
COPY --from=build /old-entrypoint.sh /old-entrypoint.sh

ARG TEMPLATE=empty_file
ENV TEMPLATE=${TEMPLATE}

COPY $TEMPLATE /tmp/custom_nginx.conf

USER root

RUN test -s $TEMPLATE || ( cp /tmp/custom_nginx.conf /custom_nginx.conf \
    && chmod +rx /custom_nginx.conf )
RUN chmod +rx /old-entrypoint.sh

HEALTHCHECK --interval=10s --timeout=10s --retries=10 CMD kong health

USER kong
