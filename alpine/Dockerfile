FROM alpine:3.13

LABEL maintainer="Kong <support@konghq.com>"

ARG ASSET=ce
ENV ASSET $ASSET

ARG EE_PORTS

COPY kong.tar.gz /tmp/kong.tar.gz

ARG KONG_VERSION=2.5.0
ENV KONG_VERSION $KONG_VERSION


ARG KONG_AMD64_SHA="ebe0cf3a3e71d202774ede5083c98e2ae39fae0459d11140f53401a66527e1b7"
ENV KONG_AMD64_SHA $KONG_AMD64_SHA

ARG KONG_ARM64_SHA="131964ce443f2d08dc98191fcc442867f2dee2f741ccee9cc519bb99c765f3cf"
ENV KONG_ARM64_SHA $KONG_ARM64_SHA

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
    fi; \
    mkdir /kong \
    && tar -C /kong -xzf /tmp/kong.tar.gz \
    && mv /kong/usr/local/* /usr/local \
    && mv /kong/etc/* /etc \
    && rm -rf /kong \
    && apk add --no-cache libstdc++ libgcc openssl pcre perl tzdata libcap zip bash zlib zlib-dev git ca-certificates \
    && apk upgrade \
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
    && if [ "$ASSET" = "ce" ] ; then \
      kong version; \
    fi

COPY docker-entrypoint.sh /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444 $EE_PORTS

STOPSIGNAL SIGQUIT

HEALTHCHECK --interval=10s --timeout=10s --retries=10 CMD kong health

CMD ["kong", "docker-start"]
