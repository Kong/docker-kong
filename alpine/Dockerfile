FROM ubuntu:bionic AS downloader

RUN apt-get update \
    && apt-get install -y curl

ARG EDITION=community
ENV EDITION $EDITION

ARG BINTRAY_USER
ENV BINTRAY_USER $BINTRAY_USER

ARG BINTRAY_KEY
ENV BINTRAY_KEY $BINTRAY_KEY

ARG BUILD_SCRIPT=build-ce.sh
COPY $BUILD_SCRIPT /tmp/build.sh

ARG LOCAL_KONG_PACKAGE=empty-kong.tar.gz
COPY $LOCAL_KONG_PACKAGE kong.tar.gz

RUN if [ "$EDITION" = "local" ] ; then exit 0 ; fi; \
    . /tmp/build.sh; \
	curl -L -u$BINTRAY_USER:$BINTRAY_KEY "$URL" -o kong.tar.gz; \
	echo "${KONG_SHA}" | sha256sum -c -
	
RUN mkdir /kong; \
	tar -C /kong -xzf kong.tar.gz

FROM alpine:3.10

LABEL maintainer="Kong <support@konghq.com>"

COPY --from=DOWNLOADER /kong/usr/local /usr/local
COPY --from=DOWNLOADER /kong/etc /etc

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