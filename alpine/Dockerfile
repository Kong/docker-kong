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

ARG LOCAL_KONG_PACKAGE=empty-kong.tar.gz
COPY $LOCAL_KONG_PACKAGE /tmp/kong.tar.gz

RUN if [ "$ASSET_LOCATION" = "local" ] ; then exit 0 ; fi; \
    . /tmp/build.sh
	
RUN mkdir /kong; \
	tar -C /kong -xzf /tmp/kong.tar.gz

FROM alpine:3.11

LABEL maintainer="Kong <support@konghq.com>"

COPY --from=downloader /kong/usr/local /usr/local
COPY --from=downloader /kong/etc /etc

RUN apk add --no-cache libgcc openssl pcre perl tzdata libcap zip \
    && adduser -S kong \
    && mkdir -p "/usr/local/kong" \
	&& chown -R kong:0 /usr/local/kong \
	&& chmod -R g=u /usr/local/kong

USER kong

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGQUIT

CMD ["kong", "docker-start"]