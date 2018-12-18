FROM alpine:3.6
LABEL maintainer="Kong Core Team <team-core@konghq.com>"

ENV KONG_VERSION 1.0.0
ENV KONG_SHA256 79001d96c28d774bcf868f281e8e3486c4027ed35d69da6560172a742240b862

RUN adduser -Su 1337 kong \
	&& mkdir -p "/usr/local/kong" \
	&& chown kong "/usr/local/kong" \
	&& apk add --no-cache --virtual .build-deps wget tar ca-certificates libcap \
	&& apk add --no-cache libgcc openssl pcre perl tzdata curl \
	&& wget -O kong.tar.gz "https://bintray.com/kong/kong-community-edition-alpine-tar/download_file?file_path=kong-community-edition-$KONG_VERSION.apk.tar.gz" \
	&& echo "$KONG_SHA256 *kong.tar.gz" | sha256sum -c - \
	&& tar -xzf kong.tar.gz -C /tmp \
	&& rm -f kong.tar.gz \
	&& cp -R /tmp/usr / \
	&& rm -rf /tmp/usr \
	&& cp -R /tmp/etc / \
	&& rm -rf /tmp/etc \
	&& setcap cap_net_raw=+ep /usr/local/openresty/nginx/sbin/nginx \
	&& apk del .build-deps

COPY docker-entrypoint.sh /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGTERM

CMD ["kong", "docker-start"]
