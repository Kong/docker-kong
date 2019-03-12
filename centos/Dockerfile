FROM centos:7
LABEL maintainer="Kong Core Team <team-core@konghq.com>"

ENV KONG_VERSION 1.1.0rc1

RUN useradd --uid 1337 kong \
  && yum install -y https://bintray.com/kong/kong-community-edition-rpm/download_file?file_path=centos/7/kong-community-edition-$KONG_VERSION.el7.noarch.rpm \
  && yum clean all \
  && mkdir -p "/usr/local/kong" \
  && chown -R kong "/usr/local/kong"

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGTERM

USER kong

CMD ["kong", "docker-start"]
