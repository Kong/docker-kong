FROM alpine:3.14

LABEL maintainer="Kong <support@konghq.com>"

ARG ASSET=ce
ENV ASSET $ASSET

ARG EE_PORTS

# hadolint ignore=DL3010
COPY kong.tar.gz /tmp/kong.tar.gz

ARG KONG_VERSION=2.6.0
ENV KONG_VERSION $KONG_VERSION

ARG KONG_AMD64_SHA="43fb5f27185e274e22b4a36b93b1b7e27afe94b9fd2efbe4ec69b8ed8a9e5902"
ARG KONG_ARM64_SHA="a057eaa6d10ecf49443ec0cac6e1b70a62ee357a777e0e169c780e18fd5c5544"

ARG KONG_ENTERPRISE_VERSION=2.6.0.0
ARG KONG_ENTERPRISE_SHA256="963291e84d3022299c9080ebeefd76e077d75a0e6d8b725fb6e9d6e08cc34692"

# hadolint ignore=DL3018
RUN set -eux; \
    arch="$(apk --print-arch)"; \
    case "${arch}" in \
      x86_64) arch='amd64'; KONG_SHA256=$KONG_AMD64_SHA ;; \
      aarch64) arch='arm64'; KONG_SHA256=$KONG_ARM64_SHA ;; \
    esac; \
    if [ "$ASSET" = "ce" ] ; then \
      apk add --no-cache --virtual .build-deps curl wget tar ca-certificates \
      && curl -fL "https://download.konghq.com/gateway-${KONG_VERSION%%.*}.x-alpine/kong-$KONG_VERSION.$arch.apk.tar.gz" -o /tmp/kong.tar.gz \
      && echo "$KONG_SHA256  /tmp/kong.tar.gz" | sha256sum -c - \
      && apk del .build-deps; \
    elif [ "$ASSET" = "ee" ] ; then \
      apk add --no-cache --virtual .build-deps curl wget tar ca-certificates \
      && curl -fL "https://download.konghq.com/gateway-${KONG_VERSION%%.*}.x-alpine/kong-enterprise-edition-$KONG_ENTERPRISE_VERSION.apk.tar.gz" -o /tmp/kong.tar.gz \
      && echo "$KONG_ENTERPRISE_SHA256  /tmp/kong.tar.gz" | sha256sum -c - \
      && apk del .build-deps \
      && apk upgrade ; \
    else \
      apk upgrade; \
    fi; \
    mkdir /kong \
    && tar -C /kong -xzf /tmp/kong.tar.gz \
    && mv /kong/usr/local/* /usr/local \
    && mv /kong/etc/* /etc \
    && rm -rf /kong \
    && apk add --no-cache libstdc++ libgcc openssl pcre perl tzdata libcap zip bash zlib zlib-dev git ca-certificates \
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
    && if [ "$ASSET" = "ce" ] || [ "$ASSET" = "ee" ] ; then \
      kong version; \
    fi

COPY docker-entrypoint.sh /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444 $EE_PORTS

STOPSIGNAL SIGQUIT

HEALTHCHECK --interval=10s --timeout=10s --retries=10 CMD kong health

CMD ["kong", "docker-start"]
