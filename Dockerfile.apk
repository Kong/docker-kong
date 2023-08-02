# When you update this file substantially, please update build_your_own_images.md as well.
FROM alpine:3.17

LABEL maintainer="Kong Docker Maintainers <docker@konghq.com> (@team-gateway-bot)"

ARG KONG_VERSION=3.3.1
ENV KONG_VERSION $KONG_VERSION

ARG KONG_AMD64_SHA="b544aa8d23b544b7ec48e943e3525f6c1f33b202522020eedf91784c87de1a3d"

ARG KONG_PREFIX=/usr/local/kong
ENV KONG_PREFIX $KONG_PREFIX

ARG ASSET=remote
ARG EE_PORTS

COPY kong.apk.tar.gz /tmp/kong.apk.tar.gz

RUN set -ex; \
    apk add --virtual .build-deps curl tar gzip ca-certificates; \
    export ARCH='amd64'; \
    KONG_SHA256=$KONG_AMD64_SHA ; \
    if [ "$ASSET" = "remote" ] ; then \
      curl -fL "https://download.konghq.com/gateway-${KONG_VERSION%%.*}.x-alpine/kong-${KONG_VERSION}.${ARCH}.apk.tar.gz" -o /tmp/kong.apk.tar.gz \
      && echo "$KONG_SHA256  /tmp/kong.apk.tar.gz" | sha256sum -c -; \
    fi \
    && tar -C / -xzf /tmp/kong.apk.tar.gz \
    && apk add --no-cache libstdc++ libgcc perl tzdata libcap zlib zlib-dev bash yaml \
    && adduser -S kong \
    && addgroup -S kong \
    && mkdir -p "${KONG_PREFIX}" \
    && chown -R kong:0 ${KONG_PREFIX} \
    && chown kong:0 /usr/local/bin/kong \
    && chmod -R g=u ${KONG_PREFIX} \
    && rm -rf /tmp/kong.apk.tar.gz \
    && ln -sf /usr/local/openresty/bin/resty /usr/local/bin/resty \
    && ln -sf /usr/local/openresty/luajit/bin/luajit /usr/local/bin/luajit \
    && ln -sf /usr/local/openresty/luajit/bin/luajit /usr/local/bin/lua \
    && ln -sf /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx \
    && apk del .build-deps \
    && kong version

COPY docker-entrypoint.sh /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444 $EE_PORTS

STOPSIGNAL SIGQUIT

HEALTHCHECK --interval=60s --timeout=10s --retries=10 CMD kong-health

CMD ["kong", "docker-start"]
