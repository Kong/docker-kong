FROM centos:7
LABEL maintainer="Kong <support@konghq.com>"

ARG ASSET=ce
ENV ASSET $ASSET

ARG LOCAL_KONG_PACKAGE=empty-kong.rpm
COPY $LOCAL_KONG_PACKAGE /tmp/kong.rpm

ARG KONG_VERSION=2.0.3
ENV KONG_VERSION $KONG_VERSION

ARG KONG_SHA256="5a97052bfc782a1a5136b0fbd006776ccd5027a9340f7e09c3c8fb2eddf22efc"
ENV KONG_SHA256 $KONG_SHA256

RUN set -ex; \
    if [ "$ASSET" = "local" ] ; then exit 0 ; \
    elif [ "$ASSET" = "ce" ] ; then \
        curl -L "https://bintray.com/kong/kong-rpm/download_file?file_path=centos/7/kong-$KONG_VERSION.el7.amd64.rpm" -o /tmp/kong.rpm && \
        echo "$KONG_SHA256  /tmp/kong.rpm" | sha256sum -c -; \
    fi

RUN yum install -y -q unzip shadow-utils \
	&& yum clean all -q \
	&& rm -fr /var/cache/yum/* /tmp/yum_save*.yumtx /root/.pki

RUN useradd kong \
	&& mkdir -p "/usr/local/kong" \
	&& yum install -y /tmp/kong.rpm \
	&& yum clean all \
	&& rm /tmp/kong.rpm \
	&& chown -R kong:0 /usr/local/kong \
	&& chown kong:0 /usr/local/bin/kong \
	&& chmod -R g=u /usr/local/kong

COPY docker-entrypoint.sh /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGQUIT

CMD ["kong", "docker-start"]
