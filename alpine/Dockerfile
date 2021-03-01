FROM alpine:3.11

LABEL maintainer="Kong <support@konghq.com>"

ARG ASSET=ce
ENV ASSET $ASSET

ARG EE_PORTS

COPY kong.tar.gz /tmp/kong.tar.gz

ARG KONG_VERSION=2.2.2
ENV KONG_VERSION $KONG_VERSION


ARG KONG_AMD64_SHA="f5e635e4241c3ad6943ff08724a363af430f7372a6d6e2892223dc2e3f9e01a7"
ENV KONG_AMD64_SHA $KONG_AMD64_SHA

ARG KONG_ARM64_SHA="435d8cd377978fbdde06e602e39584b17db832a154b5d80aa83a69c59aca9f70"
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
