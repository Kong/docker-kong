FROM registry.access.redhat.com/ubi7/ubi

MAINTAINER Kong

ENV KONG_VERSION 1.5.1

LABEL name="Kong" \
      vendor="Kong" \
      version="${KONG_VERSION}" \
      release="1" \
      url="https://konghq.com" \
      summary="Next-Generation API Platform for Modern Architectures" \
      description="Next-Generation API Platform for Modern Architectures"

COPY LICENSE /licenses/

RUN useradd kong && \
    mkdir -p "/usr/local/kong" && \
    chown -R kong:0 /usr/local/kong && \
    chmod -R g=u /usr/local/kong && \
    yum install -y https://bintray.com/kong/kong-rpm/download_file?file_path=rhel/7/kong-$KONG_VERSION.rhel7.amd64.rpm && \
    yum install -y -q unzip && \
    yum clean all

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGQUIT

CMD ["kong", "docker-start"]
