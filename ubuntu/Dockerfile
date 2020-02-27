FROM ubuntu:bionic AS downloader

RUN apt-get update \
    && apt-get install -y curl

ARG BINTRAY_USER
ENV BINTRAY_USER $BINTRAY_USER

ARG BINTRAY_KEY
ENV BINTRAY_KEY $BINTRAY_KEY

ARG BUILD_SCRIPT=build-ce.sh
COPY $BUILD_SCRIPT /tmp/build.sh

ARG ASSET_LOCATION=bintray
ENV ASSET_LOCATION $ASSET_LOCATION

ARG LOCAL_KONG_PACKAGE=empty-kong.deb
COPY $LOCAL_KONG_PACKAGE /tmp/kong.deb

RUN if [ "$ASSET_LOCATION" = "local" ] ; then exit 0 ; fi; \
    . /tmp/build.sh

FROM ubuntu:xenial
LABEL maintainer="Kong Core Team <team-core@konghq.com>"

COPY --from=downloader /tmp/kong.deb /tmp/kong.deb

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

RUN kong version

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGQUIT

CMD ["kong", "docker-start"]
