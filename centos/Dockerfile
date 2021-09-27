FROM centos:8
LABEL maintainer="Kong <support@konghq.com>"

ARG ASSET=ce
ENV ASSET $ASSET

ARG EE_PORTS

COPY kong.rpm /tmp/kong.rpm

ARG KONG_VERSION=2.5.1
ENV KONG_VERSION $KONG_VERSION

ARG KONG_SHA256="36c03c53a4e3a3f6f0968f68258fa93a584af5c33ed29fa5e05e089dfb97b730"

# hadolint ignore=DL3033
RUN set -ex; \
    if [ "$ASSET" = "ce" ] ; then \
      curl -fL https://download.konghq.com/gateway-${KONG_VERSION%%.*}.x-centos-7/Packages/k/kong-$KONG_VERSION.el7.amd64.rpm -o /tmp/kong.rpm \
      && echo "$KONG_SHA256  /tmp/kong.rpm" | sha256sum -c -; \
    fi; \
    # Please update the centos install docs if the below line is changed so that
    # end users can properly install Kong along with its required dependencies
    # and that our CI does not diverge from our docs.
    yum install -y /tmp/kong.rpm \
    && yum clean all \
    && rm /tmp/kong.rpm \
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

HEALTHCHECK --interval=10s --timeout=10s --retries=10 CMD kong health

CMD ["kong", "docker-start"]
