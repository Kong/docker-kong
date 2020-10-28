FROM ubuntu:xenial

ARG ASSET=ce
ENV ASSET $ASSET

ARG EE_PORTS

COPY kong.deb /tmp/kong.deb

ARG KONG_VERSION=2.2.0
ENV KONG_VERSION $KONG_VERSION

RUN set -ex; \
    apt-get update && \
    if [ "$ASSET" = "ce" ] ; then \
        apt-get install -y curl && \
        curl -fL "https://bintray.com/kong/kong-deb/download_file?file_path=kong-$KONG_VERSION.xenial.$(dpkg --print-architecture).deb" -o /tmp/kong.deb \
        && apt-get purge -y curl; \
    fi; \
    apt-get install -y --no-install-recommends unzip git \
	&& apt update \
    # Please update the ubuntu install docs if the below line is changed so that
    # end users can properly install Kong along with its required dependencies
    # and that our CI does not diverge from our docs.
    && apt install --yes /tmp/kong.deb \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/kong.deb \
    && chown kong:0 /usr/local/bin/kong \
    && chown -R kong:0 /usr/local/kong \
    && mkdir -p "/usr/local/kong" \
    && if [ "$ASSET" = "ce" ] ; then \
        kong version ; \
    fi;

COPY docker-entrypoint.sh /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444 $EE_PORTS

STOPSIGNAL SIGQUIT

CMD ["kong", "docker-start"]
