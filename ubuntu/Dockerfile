FROM ubuntu:jammy

ARG ASSET=ce
ENV ASSET $ASSET

ARG EE_PORTS

COPY kong.deb /tmp/kong.deb

ARG KONG_VERSION=2.8.4
ENV KONG_VERSION $KONG_VERSION

ARG KONG_AMD64_SHA="e4bc62c80f717114cc486776ee453931c5de0e8eaf0901ac11dbb4b2bae14534"
ARG KONG_ARM64_SHA="4fff44f9a0c7b06469591b7d1499a99a100109bc3f08dc412dd0eb38ff383d35"

# hadolint ignore=DL3015
RUN set -ex; \
    arch=$(dpkg --print-architecture); \
    major_minor="$(echo "${KONG_VERSION%.*}" | tr -d '.')"; \
    case "${arch}" in \
      amd64) KONG_SHA256=$KONG_AMD64_SHA ;; \
      arm64) KONG_SHA256=$KONG_ARM64_SHA ;; \
    esac; \
    apt-get update \
    && if [ "$ASSET" = "ce" ] ; then \
      CODENAME=$(grep -m1 VERSION_CODENAME /etc/os-release | cut -d = -f 2); \
      apt-get install -y curl \
      && curl -fL "https://packages.konghq.com/public/gateway-${major_minor}/deb/ubuntu/pool/${CODENAME}/main/k/ko/kong_${KONG_VERSION}/kong_${KONG_VERSION}_${arch}.deb" -o /tmp/kong.deb \
      && apt-get purge -y curl \
      && echo "$KONG_SHA256  /tmp/kong.deb" | sha256sum -c -; \
    else \
      # this needs to stay inside this "else" block so that it does not become part of the "official images" builds (https://github.com/docker-library/official-images/pull/11532#issuecomment-996219700)
      apt-get upgrade -y ; \
    fi \
    && apt-get install -y --no-install-recommends unzip git \
    # Please update the ubuntu install docs if the below line is changed so that
    # end users can properly install Kong along with its required dependencies
    # and that our CI does not diverge from our docs.
    && apt install --yes /tmp/kong.deb \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/kong.deb \
    && chown kong:0 /usr/local/bin/kong \
    && chown -R kong:0 /usr/local/kong \
    && ln -s /usr/local/openresty/bin/resty /usr/local/bin/resty \
    && ln -s /usr/local/openresty/luajit/bin/luajit /usr/local/bin/luajit \
    && ln -s /usr/local/openresty/luajit/bin/luajit /usr/local/bin/lua \
    && ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx \
    && if [ "$ASSET" = "ce" ] ; then \
      kong version ; \
    fi

COPY docker-entrypoint.sh /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444 $EE_PORTS

STOPSIGNAL SIGQUIT

HEALTHCHECK --interval=60s --timeout=10s --retries=10 CMD kong health

CMD ["kong", "docker-start"]
