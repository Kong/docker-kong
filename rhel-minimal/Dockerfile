ARG RHEL_VERSION=8

FROM registry.access.redhat.com/ubi${RHEL_VERSION}/ubi-minimal

LABEL maintainer="Kong Docker Maintainers <docker@konghq.com> (@team-gateway-bot)"

ARG KONG_VERSION=2.8.1
ENV KONG_VERSION $KONG_VERSION

ARG KONG_SHA256="8bae61982b8d439e12037e24432adc185f87113989c27c89521d8cc024b38ddc"

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

ARG RHEL_VERSION
ENV RHEL_VERSION $RHEL_VERSION

RUN set -ex; \
    if [ "$ASSET" = "ce" ] ; then \
      curl -fL "https://download.konghq.com/gateway-${KONG_VERSION%%.*}.x-rhel-${RHEL_VERSION}/Packages/k/kong-${KONG_VERSION}.rhel${RHEL_VERSION}.amd64.rpm" -o /tmp/kong.rpm \
      && echo "$KONG_SHA256  /tmp/kong.rpm" | sha256sum -c -; \
    else \
      microdnf update -y ; \
    fi \
    # findutils provides xargs (temporarily)
    && microdnf install --assumeyes --nodocs \
      findutils \
      shadow-utils \
      unzip \
    && rpm -qpR /tmp/kong.rpm \
      | grep -v rpmlib \
      | xargs -n1 -t microdnf install --assumeyes --nodocs \
    && rm -fr /var/cache/yum/* /tmp/yum_save*.yumtx /root/.pki \
    # Please update the rhel install docs if the below line is changed so that
    # end users can properly install Kong along with its required dependencies
    # and that our CI does not diverge from our docs.
    && rpm -iv /tmp/kong.rpm \
    && microdnf clean all \
    && rm /tmp/kong.rpm \
    && chown kong:0 /usr/local/bin/kong \
    && chown -R kong:0 /usr/local/kong \
    && ln -s /usr/local/openresty/bin/resty /usr/local/bin/resty \
    && ln -s /usr/local/openresty/luajit/bin/luajit /usr/local/bin/luajit \
    && ln -s /usr/local/openresty/luajit/bin/luajit /usr/local/bin/lua \
    && ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx \
    # ubi-minimal comes with libz in /usr/lib64 but is sometimes missing the
    # symlink from the versioned filenames to the unversioned.. version
    # lua-ffi-zlib expects, and the zlib-devel pkg previously provided libz.so
    && [ -s /usr/lib64/libz.so ] || ln -vs /usr/lib64/libz.so.1 /usr/lib64/libz.so \
    && kong version

COPY docker-entrypoint.sh /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444 $EE_PORTS

STOPSIGNAL SIGQUIT

HEALTHCHECK --interval=10s --timeout=10s --retries=10 CMD kong health

CMD ["kong", "docker-start"]
