FROM alpine:3.6
MAINTAINER Marco Palladino, marco@mashape.com

ENV KONG_VERSION 0.11.0
ENV KONG_SHA256 34cfd44f61a4da5d39ad7b59bad7b4790451065ff8c8c3d000b6258ab6961949

RUN apk update \
	&& apk add --virtual .build-deps wget tar ca-certificates \
	&& apk add libgcc openssl pcre perl \
	&& wget -O kong.tar.gz "https://bintray.com/kong/kong-community-edition-alpine-tar/download_file?file_path=kong-community-edition-$KONG_VERSION.apk.tar.gz" \
	&& echo "$KONG_SHA256 *kong.tar.gz" | sha256sum -c - \
	&& tar -xzf kong.tar.gz -C /tmp \
	&& rm -f kong.tar.gz \
	&& cp -R /tmp/usr / \
	&& rm -rf /tmp/usr \
	&& apk del .build-deps \
	&& rm -rf /var/cache/apk/*

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGTERM

CMD ["/usr/local/openresty/nginx/sbin/nginx", "-c", "/usr/local/kong/nginx.conf", "-p", "/usr/local/kong/"]
