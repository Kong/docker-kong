FROM ubuntu:bionic AS downloader

RUN apt-get update \
    && apt-get install -y curl

ARG EDITION=community
ENV EDITION $EDITION

ARG BINTRAY_USER
ENV BINTRAY_USER $BINTRAY_USER

ARG BINTRAY_KEY
ENV BINTRAY_KEY $BINTRAY_KEY

RUN set -eux; \
	case "${EDITION##*-}" in \
		community) \
		VERSION='2.0.0'; \
		KONG_SHA='5af1178111958b2e325c5b18690f4e7ddf064d28139ff38188b1e2e432ea99ff'; \
		URL='https://bintray.com/kong/kong-alpine-tar/download_file?file_path=kong-'$VERSION'.amd64.apk.tar.gz' ;; \
		enterprise) \
		VERSION='1.3.0.1'; \
		KONG_SHA='64a0ceabad26edfdab1173f3485859f14477485023ab6fdd2019fd6893c97bbb'; \
		URL='https://kong.bintray.com/kong-enterprise-edition-alpine-tar/kong-enterprise-edition-'$VERSION'.apk.tar.gz' ;; \
	esac; \
	\
	curl -L -u$BINTRAY_USER:$BINTRAY_KEY "$URL" -o kong.tar.gz; \
	echo "${KONG_SHA} kong.tar.gz" | sha256sum -c -; \
	mkdir /kong; \
	tar -C /kong -xzf kong.tar.gz

FROM alpine:3.10
LABEL maintainer="Kong <support@konghq.com>"

COPY --from=DOWNLOADER /kong/usr/local /usr/local
COPY --from=DOWNLOADER /kong/etc /etc

RUN apk add --no-cache libgcc openssl pcre perl tzdata libcap zip \
    && adduser -S kong \
    && mkdir -p "/usr/local/kong" \
	&& chown -R kong:0 /usr/local/kong \
	&& chmod -R g=u /usr/local/kong

USER kong

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGQUIT

CMD ["kong", "docker-start"]