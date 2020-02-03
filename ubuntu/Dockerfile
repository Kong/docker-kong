FROM ubuntu:xenial
LABEL maintainer="Kong Core Team <team-core@konghq.com>"

ENV KONG_VERSION 1.4.3

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl perl unzip \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fsSLo kong.deb https://bintray.com/kong/kong-deb/download_file?file_path=kong-${KONG_VERSION}.xenial.$(dpkg --print-architecture).deb \
    && apt-get purge -y --auto-remove ca-certificates curl \
	&& dpkg -i kong.deb

RUN set -eux; \
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) KONG_SHA256='d5e8debfd0c3a56a447a0613df1ebc8626eb262dc7af80ac7a5df4df329849c8' ;; \
		arm64) KONG_SHA256='87f2328f40754e3ca849cdaac1883de1a0da7c780f3a4f913d5ae906e33d7dce' ;; \
	esac; \
	echo "$KONG_SHA256 kong.deb" | sha256sum -c - \
	&& rm -rf kong.deb

RUN kong version

COPY docker-entrypoint.sh /docker-entrypoint.sh


ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGQUIT

CMD ["kong", "docker-start"]
