FROM alpine:3.11

LABEL maintainer="Kong <support@konghq.com>"

ARG ASSET=ce
ENV ASSET $ASSET

COPY empty-kong.tar.gz /tmp/kong.tar.gz

ARG KONG_VERSION=2.0.5
ENV KONG_VERSION $KONG_VERSION

ARG KONG_SHA256="2e78dee0e695c238cde7e607e85c2e62e44422b57c626ea12822d15ed898769b"
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
	apk add --no-cache libgcc openssl pcre perl tzdata libcap zip bash zlib git ca-certificates && \
	adduser -S kong && \
	mkdir -p "/usr/local/kong" && \
	chown -R kong:0 /usr/local/kong && \
	chown kong:0 /usr/local/bin/kong && \
	chmod -R g=u /usr/local/kong && \
	rm -rf /tmp/kong.tar.gz && \
	kong version

COPY docker-entrypoint.sh /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGQUIT

CMD ["kong", "docker-start"]