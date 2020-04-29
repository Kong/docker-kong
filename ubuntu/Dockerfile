FROM ubuntu:xenial

ARG ASSET=ce
ENV ASSET $ASSET

COPY empty-kong.deb /tmp/kong.deb

ARG KONG_VERSION=2.0.4
ENV KONG_VERSION $KONG_VERSION

RUN set -ex; \
    if [ "$ASSET" = "local" ] ; then exit 0 ; \
    elif [ "$ASSET" = "ce" ] ; then \
        apt-get update && \
        apt-get install -y curl && \
        curl -L "https://bintray.com/kong/kong-deb/download_file?file_path=kong-$KONG_VERSION.xenial.$(dpkg --print-architecture).deb" -o /tmp/kong.deb && \
        apt-get purge -y curl; \
    fi; \
    apt-get update \
    && apt-get install -y --no-install-recommends perl unzip \
    && rm -rf /var/lib/apt/lists/* \
	&& dpkg -i /tmp/kong.deb \
	&& rm -rf /tmp/kong.deb \
	&& useradd -ms /bin/bash kong \
    && mkdir -p "/usr/local/kong" \
	&& chown -R kong:0 /usr/local/kong \
	&& chown kong:0 /usr/local/bin/kong \
	&& chmod -R g=u /usr/local/kong

COPY docker-entrypoint.sh /docker-entrypoint.sh

USER kong

RUN kong version

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGQUIT

CMD ["kong", "docker-start"]
