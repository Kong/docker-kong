ARG RESTY_IMAGE_BASE="centos"
ARG RESTY_IMAGE_TAG="7"
FROM ${RESTY_IMAGE_BASE}:${RESTY_IMAGE_TAG}
LABEL maintainer="Kong <support@konghq.com>"

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
