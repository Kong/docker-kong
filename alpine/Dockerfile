FROM alpine:3.6
MAINTAINER Marco Palladino, marco@mashape.com

ENV KONG_VERSION 0.11.1
ENV KONG_SHA256 2291f92a935d850fe850394834c7737e99a82c37b0024637b4e17adfa1a4ef28

RUN apk update \
	&& apk add --virtual .build-deps wget tar ca-certificates \
	&& apk add libgcc openssl pcre perl tzdata \
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
