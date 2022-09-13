FROM alpine:3.16

LABEL maintainer="Kong Docker Maintainers <docker@konghq.com> (@team-gateway-bot)"

ARG ASSET=ce
ENV ASSET $ASSET

ARG EE_PORTS

# hadolint ignore=DL3010
COPY kong.tar.gz /tmp/kong.tar.gz

ARG KONG_VERSION=3.0.0
ENV KONG_VERSION $KONG_VERSION

ARG KONG_AMD64_SHA="b8e21beb32f803fae0959694ce7b6cec796a4159757e61b9cc0d30bed9682d10"
ARG KONG_ARM64_SHA="4c5407c5ef2f0f29468e15ea4dc6a3f27011dbde3ce18170e4a4fd7e2bb2c03b"

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
    else \
      # this needs to stay inside this "else" block so that it does not become part of the "official images" builds (https://github.com/docker-library/official-images/pull/11532#issuecomment-996219700)
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
