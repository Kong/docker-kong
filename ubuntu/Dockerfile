FROM ubuntu:xenial
LABEL maintainer="Kong Core Team <team-core@konghq.com>"

ENV KONG_VERSION 1.4.2

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl perl unzip \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fsSLo kong.deb https://bintray.com/kong/kong-deb/download_file?file_path=kong-${KONG_VERSION}.xenial.$(dpkg --print-architecture).deb \
    && apt-get purge -y --auto-remove ca-certificates curl \
	&& dpkg -i kong.deb

RUN set -eux; \
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) KONG_SHA256='66a8dd86a3abdf4abe5a78b7c06f2603a8026c8587d4bf9c20d0227e866180a8' ;; \
		arm64) KONG_SHA256='c5d4248ce97f0b1685c7a4bb0f60722726080d510730aa7a4b20cbe4dca20b6e' ;; \
	esac; \
	echo "$KONG_SHA256 kong.deb" | sha256sum -c - \
	&& rm -rf kong.deb

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGQUIT

CMD ["kong", "docker-start"]
