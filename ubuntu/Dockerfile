FROM ubuntu:xenial

ARG ASSET=ce
ENV ASSET $ASSET

ARG EE_PORTS

COPY kong.deb /tmp/kong.deb

ARG KONG_VERSION=2.1.0beta.1
ENV KONG_VERSION $KONG_VERSION

RUN set -ex; \
    if [ "$ASSET" = "ce" ] ; then \
        apt-get update && \
        apt-get install -y curl && \
        curl -fL "https://bintray.com/kong/kong-prerelease/download_file?file_path=kong-$KONG_VERSION.xenial.$(dpkg --print-architecture).deb" -o /tmp/kong.deb \
        && apt-get purge -y curl; \
    fi; \
    apt-get update \
    && apt-get install -y --no-install-recommends perl unzip git zlib1g \
    && rm -rf /var/lib/apt/lists/* \
	&& dpkg -i /tmp/kong.deb \
	&& rm -rf /tmp/kong.deb \
	&& useradd -ms /bin/bash kong \
    && mkdir -p "/usr/local/kong" \
	&& chown -R kong:0 /usr/local/kong \
	&& chown kong:0 /usr/local/bin/kong \
	&& chmod -R g=u /usr/local/kong \
	&& kong version

COPY docker-entrypoint.sh /docker-entrypoint.sh

USER kong

RUN kong version

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444 $EE_PORTS

STOPSIGNAL SIGQUIT

CMD ["kong", "docker-start"]
