FROM ubuntu:bionic AS downloader

RUN apt-get update \
    && apt-get install -y curl

ARG BINTRAY_USER
ENV BINTRAY_USER $BINTRAY_USER

ARG BINTRAY_KEY
ENV BINTRAY_KEY $BINTRAY_KEY

ARG BUILD_SCRIPT=build-ce.sh
COPY $BUILD_SCRIPT /tmp/build.sh

ARG ASSET_LOCATION=bintray
ENV ASSET_LOCATION $ASSET_LOCATION

ARG LOCAL_KONG_PACKAGE=empty-kong.rpm
COPY $LOCAL_KONG_PACKAGE /tmp/kong.rpm

RUN if [ "$ASSET_LOCATION" = "local" ] ; then exit 0 ; fi; \
    . /tmp/build.sh

FROM registry.access.redhat.com/ubi7/ubi

MAINTAINER Kong

LABEL name="Kong" \
      vendor="Kong" \
      version="${KONG_VERSION}" \
      release="1" \
      url="https://konghq.com" \
      summary="Next-Generation API Platform for Modern Architectures" \
      description="Next-Generation API Platform for Modern Architectures"

COPY --from=downloader /tmp/kong.rpm /tmp/kong.rpm
COPY LICENSE /licenses/

RUN yum install -y -q unzip \
	&& yum clean all -q \
	&& rm -fr /var/cache/yum/* /tmp/yum_save*.yumtx /root/.pki

RUN useradd kong \
	&& mkdir -p "/usr/local/kong" \
	&& yum install -y /tmp/kong.rpm \
	&& yum clean all \
	&& rm /tmp/kong.rpm \
	&& chown -R kong:0 /usr/local/kong \
	&& chmod -R g=u /usr/local/kong

USER kong

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGQUIT

CMD ["kong", "docker-start"]