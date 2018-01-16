FROM alpine:3.6
LABEL maintainer Marco Palladino, marco@mashape.com

ENV KONG_VERSION 0.12.0
ENV KONG_SHA256 43683a0cde80fb3a952e84d1c7748fc3e178a8902ce543b2baf5c7c65b7b52d9

RUN apk add --no-cache --virtual .build-deps wget tar ca-certificates \
	&& apk add --no-cache libgcc openssl pcre perl tzdata \
	&& wget -O kong.tar.gz "https://bintray.com/kong/kong-community-edition-alpine-tar/download_file?file_path=kong-community-edition-$KONG_VERSION.apk.tar.gz" \
	&& echo "$KONG_SHA256 *kong.tar.gz" | sha256sum -c - \
	&& tar -xzf kong.tar.gz -C /tmp \
	&& rm -f kong.tar.gz \
	&& cp -R /tmp/usr / \
	&& rm -rf /tmp/usr \
	&& cp -R /tmp/etc / \
	&& rm -rf /tmp/etc \
	&& apk del .build-deps

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGTERM

CMD ["/usr/local/openresty/nginx/sbin/nginx", "-c", "/usr/local/kong/nginx.conf", "-p", "/usr/local/kong/"]
