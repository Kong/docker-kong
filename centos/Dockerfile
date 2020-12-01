FROM centos:7
LABEL maintainer="Kong <support@konghq.com>"

ARG ASSET=ce
ENV ASSET $ASSET

ARG EE_PORTS

COPY kong.rpm /tmp/kong.rpm

ARG KONG_VERSION=2.2.1
ENV KONG_VERSION $KONG_VERSION

ARG KONG_SHA256="aed53fd4779559d9ff618c634e4c3c3281cca550d9b1bcdae8e7359602bd6771"

RUN set -ex; \
  if [ "$ASSET" = "ce" ] ; then \
    curl -fL "https://bintray.com/kong/kong-rpm/download_file?file_path=centos/7/kong-$KONG_VERSION.el7.amd64.rpm" -o /tmp/kong.rpm \
    && echo "$KONG_SHA256  /tmp/kong.rpm" | sha256sum -c -; \
  fi; \
  yum install -y -q unzip shadow-utils git \
  && yum clean all -q \
  && rm -fr /var/cache/yum/* /tmp/yum_save*.yumtx /root/.pki \
  # Please update the centos install docs if the below line is changed so that
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
