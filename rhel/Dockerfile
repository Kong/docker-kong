FROM registry.access.redhat.com/ubi7/ubi:7.9@sha256:baccc7f4a9df7f4872116e254efb4e0e1b7d5d8e557947c02d44230ce7b905bc

LABEL maintainer="Kong Docker Maintainers <docker@konghq.com> (@team-gateway-bot)"

ARG KONG_VERSION=2.8.1
ENV KONG_VERSION $KONG_VERSION

ARG KONG_SHA256="4f2d073122c97be80de301e6037d0913f15de1d8bb6eea2871542e9a4c164c72"

# RedHat required labels
LABEL name="Kong" \
      vendor="Kong" \
      version="$KONG_VERSION" \
      release="1" \
      url="https://konghq.com" \
      summary="Next-Generation API Platform for Modern Architectures" \
      description="Next-Generation API Platform for Modern Architectures"

# RedHat required LICENSE file approved path
COPY LICENSE /licenses/

ARG ASSET=ce
ENV ASSET $ASSET

ARG EE_PORTS

COPY kong.rpm /tmp/kong.rpm

RUN set -ex; \
    if [ "$ASSET" = "ce" ] ; then \
      curl -fL "https://download.konghq.com/gateway-${KONG_VERSION%%.*}.x-rhel-7/Packages/k/kong-$KONG_VERSION.rhel7.amd64.rpm" -o /tmp/kong.rpm \
      && echo "$KONG_SHA256  /tmp/kong.rpm" | sha256sum -c - \
      || exit 1; \
    else \
      yum update -y \
      && yum upgrade -y ; \
    fi \
    && yum install -y -q unzip shadow-utils \
    && yum clean all -q \
    && rm -fr /var/cache/yum/* /tmp/yum_save*.yumtx /root/.pki \
    # Please update the rhel install docs if the below line is changed so that
    # end users can properly install Kong along with its required dependencies
    # and that our CI does not diverge from our docs.
    && yum localinstall -y /tmp/kong.rpm \
    && yum clean all \
    && rm /tmp/kong.rpm \
    && chown kong:0 /usr/local/bin/kong \
    && chown -R kong:0 /usr/local/kong \
    && ln -s /usr/local/openresty/bin/resty /usr/local/bin/resty \
    && ln -s /usr/local/openresty/luajit/bin/luajit /usr/local/bin/luajit \
    && ln -s /usr/local/openresty/luajit/bin/luajit /usr/local/bin/lua \
    && ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx \
    && kong version

COPY docker-entrypoint.sh /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444 $EE_PORTS

STOPSIGNAL SIGQUIT

HEALTHCHECK --interval=10s --timeout=10s --retries=10 CMD kong health

CMD ["kong", "docker-start"]
