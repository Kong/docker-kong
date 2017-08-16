FROM alpine
MAINTAINER Marco Palladino, marco@mashape.com

ENV KONG_VERSION 0.11.0rc2

RUN apk update \
	&& apk add --virtual .build-deps wget tar ca-certificates \
	&& apk add libgcc openssl pcre perl \
	&& wget "https://bintray.com/kong/kong-community-edition-alpine-tar/download_file?file_path=kong-community-edition-0.11.0.apk.tar.gz" -O - | tar xz -C /tmp \
	&& cp -R /tmp/usr / \
	&& rm -rf /tmp/usr \
	&& apk del .build-deps \
	&& rm -rf /var/cache/apk/*

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGTERM

CMD ["/usr/local/openresty/nginx/sbin/nginx", "-c", "/usr/local/kong/nginx.conf", "-p", "/usr/local/kong/"]
