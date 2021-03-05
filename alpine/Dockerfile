FROM alpine:3.11

LABEL maintainer="Kong <support@konghq.com>"

ARG ASSET=ce
ENV ASSET $ASSET

ARG EE_PORTS

COPY kong.tar.gz /tmp/kong.tar.gz

ARG KONG_VERSION=2.3.3
ENV KONG_VERSION $KONG_VERSION


ARG KONG_AMD64_SHA="82a4eac75d45a1f2ce65ae185467e20533428b3d368e5e091fe4ddf427296e0b"
ENV KONG_AMD64_SHA $KONG_AMD64_SHA

ARG KONG_ARM64_SHA="b2b8a0fe0cdb81d244e08c23a3143e4ae08b7c771a2cc35e24ffabfc54f4ba60"
ENV KONG_ARM64_SHA $KONG_ARM64_SHA

RUN set -eux; \
	arch="$(apk --print-arch)"; \
	case "${arch}" in \
		x86_64) arch='amd64'; KONG_SHA256=$KONG_AMD64_SHA ;; \
		aarch64) arch='arm64'; KONG_SHA256=$KONG_ARM64_SHA ;; \
	esac; \
    if [ "$ASSET" = "ce" ] ; then \
        apk add --no-cache --virtual .build-deps curl wget tar ca-certificates && \
        curl -fL "https://bintray.com/kong/kong-alpine-tar/download_file?file_path=kong-$KONG_VERSION.$arch.apk.tar.gz" -o /tmp/kong.tar.gz && \
        echo "$KONG_SHA256  /tmp/kong.tar.gz" | sha256sum -c -; \
        apk del .build-deps; \
    fi; \
    mkdir /kong; \
    tar -C /kong -xzf /tmp/kong.tar.gz && \
    mv /kong/usr/local/* /usr/local && \
    mv /kong/etc/* /etc && \
    rm -rf /kong && \
    apk add --no-cache libstdc++ libgcc openssl pcre perl tzdata libcap zip bash   zlib zlib-dev git ca-certificates && \
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
