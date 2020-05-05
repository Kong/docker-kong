ARG RESTY_IMAGE_BASE="ubuntu"
ARG RESTY_IMAGE_TAG="xenial"
FROM ${RESTY_IMAGE_BASE}:${RESTY_IMAGE_TAG}

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
    apt-get update \
    && apt-get install -y curl && \
    . /tmp/build.sh && \
    apt-get purge -yf curl

RUN apt-get update \
    && apt-get install -y --no-install-recommends perl unzip zlibc \
    && rm -rf /var/lib/apt/lists/* \
	&& dpkg -i /tmp/kong.deb \
	&& rm -rf /tmp/kong.deb

RUN useradd -ms /bin/bash kong \
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
