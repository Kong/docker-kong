FROM debian:stretch

ENV KONG_VERSION 1.0.0

RUN useradd --uid 1337 kong \
      && apt-get update \
      && apt-get install -y wget openssl libpcre3 procps perl \
      && wget -O kong.deb "https://bintray.com/kong/kong-community-edition-deb/download_file?file_path=dists/kong-community-edition-1.0.0.stretch.all.deb" \
      && dpkg -i kong.deb \
      && rm -f kong.deb

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGTERM

CMD ["kong", "docker-start"]
