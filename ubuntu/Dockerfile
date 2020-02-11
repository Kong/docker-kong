FROM ubuntu:bionic AS downloader

RUN apt-get update \
    && apt-get install -y curl

RUN VERSION='2.0.0' \
    && curl -fsSLo /tmp/kong.deb https://bintray.com/kong/kong-deb/download_file?file_path=kong-$VERSION.xenial.$(dpkg --print-architecture).deb

FROM ubuntu:xenial
LABEL maintainer="Kong Core Team <team-core@konghq.com>"

COPY --from=DOWNLOADER /tmp/kong.deb /tmp/kong.deb

RUN apt-get update \
    && apt-get install -y --no-install-recommends perl unzip \
    && rm -rf /var/lib/apt/lists/* \
	&& dpkg -i /tmp/kong.deb \
	&& rm -rf /tmp/kong.deb

RUN useradd -ms /bin/bash kong \
    && mkdir -p "/usr/local/kong" \
	&& chown -R kong:0 /usr/local/kong \
	&& chmod -R g=u /usr/local/kong

USER kong

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGQUIT

CMD ["kong", "docker-start"]
