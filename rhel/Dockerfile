FROM registry.access.redhat.com/rhel7

MAINTAINER Kong

ENV KONG_VERSION 0.14.1

LABEL name="Kong" \
      vendor="Kong" \
      version="${KONG_VERSION}" \
      release="1" \
      url="https://konghq.com" \
      summary="Next-Generation API Platform for Modern Architectures" \
      description="Next-Generation API Platform for Modern Architectures"

COPY LICENSE /licenses/

RUN yum install -y wget https://bintray.com/kong/kong-community-edition-rpm/download_file?file_path=rhel/7/kong-community-edition-$KONG_VERSION.rhel7.noarch.rpm && \
    yum clean all

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGTERM

CMD ["kong", "docker-start"]
