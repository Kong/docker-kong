FROM ubuntu:jammy

LABEL maintainer="Kong Docker Maintainers <docker@konghq.com> (@team-gateway-bot)"

ARG ASSET=ce
ENV ASSET $ASSET

ARG EE_PORTS

COPY kong.deb /tmp/kong.deb

ARG KONG_VERSION=3.5.0
ENV KONG_VERSION $KONG_VERSION

ARG KONG_AMD64_SHA="ad00de50a799f533e0e88d10063022b41e52bc50fa3c9169ce451c9561e2cd5d"
ARG KONG_ARM64_SHA="d34c29ba688986f2bb23e118478f450d8a49755d1178ecc5d7184e46944b4881"

# hadolint ignore=DL3015
RUN set -ex; \
    arch=$(dpkg --print-architecture); \
    case "${arch}" in \
      amd64) KONG_SHA256=$KONG_AMD64_SHA ;; \
      arm64) KONG_SHA256=$KONG_ARM64_SHA ;; \
    esac; \
    apt-get update \
    && if [ "$ASSET" = "ce" ] ; then \
      apt-get install -y --no-install-recommends curl ca-certificates \
      && UBUNTU_CODENAME=$(cat /etc/os-release | grep UBUNTU_CODENAME | cut -d = -f 2) \
      && curl -fL https://download.konghq.com/gateway-${KONG_VERSION%%.*}.x-ubuntu-${UBUNTU_CODENAME}/pool/all/k/kong/kong_${KONG_VERSION}_$arch.deb -o /tmp/kong.deb \
      && apt-get purge -y curl \
      && echo "$KONG_SHA256  /tmp/kong.deb" | sha256sum -c - \
      || exit 1; \
    else \
      # this needs to stay inside this "else" block so that it does not become part of the "official images" builds (https://github.com/docker-library/official-images/pull/11532#issuecomment-996219700)
      apt-get upgrade -y ; \
    fi; \
    apt-get install -y --no-install-recommends unzip git \
    # Please update the ubuntu install docs if the below line is changed so that
    # end users can properly install Kong along with its required dependencies
    # and that our CI does not diverge from our docs.
    && apt install --yes --no-install-recommends /tmp/kong.deb \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/kong.deb \
    && chown kong:0 /usr/local/bin/kong \
    && chown -R kong:0 /usr/local/kong \
    && ln -sf /usr/local/openresty/bin/resty /usr/local/bin/resty \
    && ln -sf /usr/local/openresty/luajit/bin/luajit /usr/local/bin/luajit \
    && ln -sf /usr/local/openresty/luajit/bin/luajit /usr/local/bin/lua \
    && ln -sf /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx \
    && if [ "$ASSET" = "ce" ] ; then \
      kong version ; \
    fi

COPY docker-entrypoint.sh /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444 $EE_PORTS

STOPSIGNAL SIGQUIT

HEALTHCHECK --interval=10s --timeout=10s --retries=10 CMD kong health

CMD ["kong", "docker-start"]
