FROM alpine:3.11

LABEL maintainer="Kong <support@konghq.com>"

ARG ASSET=ce
ENV ASSET $ASSET

COPY empty-kong.tar.gz /tmp/kong.tar.gz

ARG KONG_VERSION=2.0.4
ENV KONG_VERSION $KONG_VERSION

ARG KONG_SHA256="457dd0172ae2de2e0b71ce625f78e06449faf38fd734dd6825eb7782d74cb77e"
ENV KONG_SHA256 $KONG_SHA256

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
	apk add --no-cache libgcc openssl pcre perl tzdata libcap zip bash zlib zlib-dev git && \
	adduser -S kong && \
	mkdir -p "/usr/local/kong" && \
	chown -R kong:0 /usr/local/kong && \
	chown kong:0 /usr/local/bin/kong && \
	chmod -R g=u /usr/local/kong && \
	rm -rf /tmp/kong.tar.gz

COPY docker-entrypoint.sh /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGQUIT

CMD ["kong", "docker-start"]