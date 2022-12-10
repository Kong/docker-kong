# When you update this file substantially, please update build_your_own_images.md as well.
FROM alpine:3.16

LABEL maintainer="Kong Docker Maintainers <docker@konghq.com> (@team-gateway-bot)"

ARG KONG_VERSION=3.1.1
ENV KONG_VERSION $KONG_VERSION

ARG KONG_AMD64_SHA="9194977814e91b6997ce4795957d9b4bcec9d220667e01a08ade7ac64704f57c"
ARG KONG_ARM64_SHA="92d98307a3193602bbe4dbed2d099cde5404a8acd09d53f0b9a9f2bcf6038500"

ARG ASSET=remote
ARG EE_PORTS

COPY kong.apk.tar.gz /tmp/kong.apk.tar.gz

RUN set -ex; \
    apk add --virtual .build-deps curl tar gzip ca-certificates; \
    arch="$(apk --print-arch)"; \
    case "${arch}" in \
      x86_64) export ARCH='amd64'; KONG_SHA256=$KONG_AMD64_SHA ;; \
      aarch64) export ARCH='arm64'; KONG_SHA256=$KONG_ARM64_SHA ;; \
    esac; \
    if [ "$ASSET" = "remote" ] ; then \
      curl -fL "https://download.konghq.com/gateway-${KONG_VERSION%%.*}.x-alpine/kong-${KONG_VERSION}.${ARCH}.apk.tar.gz" -o /tmp/kong.apk.tar.gz \
      && echo "$KONG_SHA256  /tmp/kong.apk.tar.gz" | sha256sum -c -; \
    fi \
    && tar -C / -xzf /tmp/kong.apk.tar.gz \
    && apk add --no-cache libstdc++ libgcc pcre perl tzdata libcap zlib zlib-dev bash \
    && adduser -S kong \
    && addgroup -S kong \
    && mkdir -p "/usr/local/kong" \
    && chown -R kong:0 /usr/local/kong \
    && chown kong:0 /usr/local/bin/kong \
    && chmod -R g=u /usr/local/kong \
    && rm -rf /tmp/kong.tar.gz \
    && ln -s /usr/local/openresty/bin/resty /usr/local/bin/resty \
    && ln -s /usr/local/openresty/luajit/bin/luajit /usr/local/bin/luajit \
    && ln -s /usr/local/openresty/luajit/bin/luajit /usr/local/bin/lua \
    && ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx \
    && apk del .build-deps \
    && kong version

COPY docker-entrypoint.sh /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444 $EE_PORTS

STOPSIGNAL SIGQUIT

HEALTHCHECK --interval=10s --timeout=10s --retries=10 CMD kong health

CMD ["kong", "docker-start"]
