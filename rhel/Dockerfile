ARG RESTY_IMAGE_TAG="7"

FROM registry.access.redhat.com/ubi${RESTY_IMAGE_TAG}/ubi

ARG RESTY_IMAGE_TAG="7"
ENV RESTY_IMAGE_TAG $RESTY_IMAGE_TAG

MAINTAINER Kong

LABEL name="Kong" \
      vendor="Kong" \
      version="2.0.3" \
      release="1" \
      url="https://konghq.com" \
      summary="Next-Generation API Platform for Modern Architectures" \
      description="Next-Generation API Platform for Modern Architectures"

COPY LICENSE /licenses/

ARG ASSET=ce
ENV ASSET $ASSET

ARG LOCAL_KONG_PACKAGE=empty-kong.rpm
COPY $LOCAL_KONG_PACKAGE /tmp/kong.rpm

ARG KONG_VERSION=2.0.3
ENV KONG_VERSION $KONG_VERSION

ARG KONG_SHA256="886ce4e5b8cc3ecd38e82300114f151f4af440386397696602c041f65a7f2b9d"
ENV KONG_SHA256 $KONG_SHA256

RUN set -ex; \
    if [ "$ASSET" = "local" ] ; then exit 0 ; \
    elif [ "$ASSET" = "ce" ] ; then \
        curl -L "https://bintray.com/kong/kong-rpm/download_file?file_path=rhel/7/kong-$KONG_VERSION.rhel$RESTY_IMAGE_TAG.amd64.rpm" -o /tmp/kong.rpm && \
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