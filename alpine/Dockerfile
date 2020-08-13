FROM alpine:3.11

LABEL maintainer="Kong <support@konghq.com>"

ARG ASSET=ce
ENV ASSET $ASSET

ARG EE_PORTS

COPY kong.tar.gz /tmp/kong.tar.gz

ARG KONG_VERSION=2.1.2
ENV KONG_VERSION $KONG_VERSION

ARG KONG_SHA256="bd36b7b17e38949a1e4747fad4b6fe34c30c81e4a4a94dae5dd0073871e841bd"

RUN set -ex; \
    if [ "$ASSET" = "ce" ] ; then \
        apk add --no-cache --virtual .build-deps curl wget tar ca-certificates && \
        curl -fL "https://bintray.com/kong/kong-alpine-tar/download_file?file_path=kong-$KONG_VERSION.amd64.apk.tar.gz" -o /tmp/kong.tar.gz && \
        echo "$KONG_SHA256  /tmp/kong.tar.gz" | sha256sum -c -; \
        apk del .build-deps; \
    fi; \
    mkdir /kong; \
	tar -C /kong -xzf /tmp/kong.tar.gz && \
	mv /kong/usr/local/* /usr/local && \
	mv /kong/etc/* /etc && \
	rm -rf /kong && \
	apk add --no-cache libstdc++ libgcc openssl pcre perl tzdata libcap zip bash zlib zlib-dev git ca-certificates && \
	adduser -S kong && \
	mkdir -p "/usr/local/kong" && \
	chown -R kong:0 /usr/local/kong && \
	chown kong:0 /usr/local/bin/kong && \
	chmod -R g=u /usr/local/kong && \
	rm -rf /tmp/kong.tar.gz && \
  if [ "$ASSET" = "ce" ] ; then \
    kong version ; \
  fi;

COPY docker-entrypoint.sh /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444 $EE_PORTS

STOPSIGNAL SIGQUIT

CMD ["kong", "docker-start"]
