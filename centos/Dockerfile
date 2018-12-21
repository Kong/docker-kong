FROM centos:7
LABEL maintainer="Kong Core Team <team-core@konghq.com>"

ENV KONG_VERSION 0.15.0

RUN useradd --uid 1337 kong \
    && yum install -y https://bintray.com/kong/kong-community-edition-rpm/download_file?file_path=centos/7/kong-community-edition-$KONG_VERSION.el7.noarch.rpm \
    && yum clean all

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGTERM

CMD ["kong", "docker-start"]
