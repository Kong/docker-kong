FROM alpine:3.6
LABEL maintainer="Kong Core Team <team-core@konghq.com>"

ENV KONG_VERSION 1.1.0rc1
ENV KONG_SHA256 72abd186181b5ebb263c4e12db5d89cac529e2b5ca858015d44a34d560755b35

RUN adduser -Su 1337 -g root kong  \
	&& mkdir -p "/usr/local/kong" \
	&& apk add --no-cache --virtual .build-deps wget tar ca-certificates \
	&& apk add --no-cache libgcc openssl pcre perl tzdata curl libcap su-exec \
	&& wget -O kong.tar.gz "https://bintray.com/kong/kong-community-edition-alpine-tar/download_file?file_path=kong-community-edition-$KONG_VERSION.apk.tar.gz" \
	&& echo "$KONG_SHA256 *kong.tar.gz" | sha256sum -c - \
	&& tar -xzf kong.tar.gz -C /tmp \
	&& rm -f kong.tar.gz \
	&& cp -R /tmp/usr / \
	&& rm -rf /tmp/usr \
	&& cp -R /tmp/etc / \
	&& rm -rf /tmp/etc \
	&& apk del .build-deps \
	&& chown -R kong /usr/local/kong \
	&& chgrp -R 0 /usr/local/kong \
	&& chmod -R g=u /usr/local/kong

# for transparent proxy usage enable setcup for kong
RUN chown kong /usr/local/openresty/nginx/sbin/ \
	&& cp /usr/local/openresty/nginx/sbin/nginx /usr/local/openresty/nginx/sbin/nginx-transparent \
	&& cp /usr/local/openresty/nginx/sbin/nginx /usr/local/openresty/nginx/sbin/nginx-non-transparent \
	&& rm /usr/local/openresty/nginx/sbin/nginx \
    && setcap cap_net_raw=+ep /usr/local/openresty/nginx/sbin/nginx-transparent

COPY docker-entrypoint.sh /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGTERM

CMD ["kong", "docker-start"]
