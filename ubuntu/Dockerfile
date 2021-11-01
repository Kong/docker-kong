FROM ubuntu:focal

ARG ASSET=ce
ENV ASSET $ASSET

ARG EE_PORTS

COPY kong.deb /tmp/kong.deb

ARG KONG_VERSION=2.6.0
ENV KONG_VERSION $KONG_VERSION

ARG KONG_SHA256="53adb6b1a5fd95b388a0c0bcf57b135dd9773acefa9567e092d5e49d95a76c91"

ARG KONG_EE_VERSION=2.6.0.0
ARG KONG_EE_SHA256="71f4ee3a1a2bba384a41275e29cce4c5737925188d095d2ab92e0e27504311c5"

# hadolint ignore=DL3015
RUN set -ex \
    && apt-get update \
    && if [ "$ASSET" = "ce" ] ; then \
      apt-get install -y curl \
      && curl -fL https://download.konghq.com/gateway-${KONG_VERSION%%.*}.x-ubuntu-$(cat /etc/os-release | grep UBUNTU_CODENAME | cut -d = -f 2)/pool/all/k/kong/kong_${KONG_VERSION}_amd64.deb -o /tmp/kong.deb \
      && apt-get purge -y curl \
      && echo "$KONG_SHA256  /tmp/kong.deb" | sha256sum -c -; \
    elif [ "$ASSET" = "ee" ] ; then \
      apt-get install -y curl \
      && curl -fL https://download.konghq.com/gateway-${KONG_VERSION%%.*}.x-ubuntu-$(cat /etc/os-release | grep UBUNTU_CODENAME | cut -d = -f 2)/pool/all/k/kong-enterprise-edition/kong-enterprise-edition_${KONG_EE_VERSION}_all.deb -o /tmp/kong.deb \
      && apt-get purge -y curl \
      && apt-get upgrade -y \
      && echo "$KONG_EE_SHA256  /tmp/kong.deb" | sha256sum -c -; \
    else \
      apt-get upgrade -y ; \
    fi; \
    apt-get install -y --no-install-recommends unzip git \
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
    && if [ "$ASSET" = "ce" ] || [ "$ASSET" = "ee" ] ; then \
      kong version ; \
    fi

COPY docker-entrypoint.sh /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444 $EE_PORTS

STOPSIGNAL SIGQUIT

HEALTHCHECK --interval=10s --timeout=10s --retries=10 CMD kong health

CMD ["kong", "docker-start"]
