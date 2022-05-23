ARG RHEL_VERSION=7

FROM registry.access.redhat.com/ubi${RHEL_VERSION}/ubi

MAINTAINER Kong

LABEL name="Kong" \
      vendor="Kong" \
      version="2.4.0" \
      release="1" \
      url="https://konghq.com" \
      summary="Next-Generation API Platform for Modern Architectures" \
      description="Next-Generation API Platform for Modern Architectures"

COPY LICENSE /licenses/

ARG ASSET=ce
ENV ASSET $ASSET

ARG EE_PORTS

COPY kong.rpm /tmp/kong.rpm

ARG KONG_VERSION=2.4.2
ENV KONG_VERSION $KONG_VERSION

ARG RHEL_VERSION
ENV RHEL_VERSION $RHEL_VERSION

ARG KONG_SHA256="e154b381ae84237fa8d5303ffa42af109bd30df6130e40ef9d7e4de06c7f4a29"
ENV KONG_SHA256 $KONG_SHA256

RUN set -ex; \
    if [ "$ASSET" = "ce" ] ; then \
        curl -fL "https://download.konghq.com/gateway-${KONG_VERSION%%.*}.x-rhel-$RHEL_VERSION/Packages/k/kong-$KONG_VERSION.rhel${RHEL_VERSION}.amd64.rpm" -o /tmp/kong.rpm \
        && echo "$KONG_SHA256  /tmp/kong.rpm" | sha256sum -c -; \
    fi; \
    yum install -y -q unzip shadow-utils \
    && yum clean all -q \
    && rm -fr /var/cache/yum/* /tmp/yum_save*.yumtx /root/.pki \
    # Please update the rhel install docs if the below line is changed so that
    # end users can properly install Kong along with its required dependencies
    # and that our CI does not diverge from our docs.
    && yum install -y /tmp/kong.rpm \
    && yum clean all \
    && rm /tmp/kong.rpm \
    && chown kong:0 /usr/local/bin/kong \
    && chown -R kong:0 /usr/local/kong && \
    if [ "$ASSET" = "ce" ] ; then \
      kong version ; \
    fi;

COPY docker-entrypoint.sh /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444 $EE_PORTS

STOPSIGNAL SIGQUIT

CMD ["kong", "docker-start"]
