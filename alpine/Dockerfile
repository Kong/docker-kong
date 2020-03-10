FROM alpine:3.11

LABEL maintainer="Kong <support@konghq.com>"

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
    apk add --no-cache --virtual .build-deps curl wget tar ca-certificates && \
    . /tmp/build.sh && \
    apk del .build-deps
	
RUN mkdir /kong; \
	tar -C /kong -xzf /tmp/kong.tar.gz && \
	mv /kong/usr/local/* /usr/local && \
	mv /kong/etc/* /etc && \
	rm -rf /kong

RUN apk add --no-cache libgcc openssl pcre perl tzdata libcap zip \
    && adduser -S kong \
    && mkdir -p "/usr/local/kong" \
	&& chown -R kong:0 /usr/local/kong \
	&& chown kong:0 /usr/local/bin/kong \
	&& chmod -R g=u /usr/local/kong

COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod 777 /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGQUIT

CMD ["kong", "docker-start"]