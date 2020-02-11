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
		KONG_SHA='5a7454cc205d3c6b0f24193e3b4f5192f2afb0cdfc217ec253b63afd316169d9'; \
		URL='https://bintray.com/kong/kong-rpm/download_file?file_path=centos/7/kong-'$VERSION'.el7.amd64.rpm' ;; \
		enterprise) \
		VERSION='1.3.0.1'; \
		KONG_SHA='56938ea59bb608d2369d714bce1462b0b4f7e30ad9bdfa14135fa95356f8ffb3'; \
		URL='https://kong.bintray.com/kong-enterprise-edition-rpm/centos/7/kong-enterprise-edition-'$VERSION'.el7.noarch.rpm' ;; \
	esac; \
	\
	curl -L -u$BINTRAY_USER:$BINTRAY_KEY "$URL" -o /tmp/kong.rpm; \
	echo "${KONG_SHA} /tmp/kong.rpm" | sha256sum -c -

FROM centos:7
LABEL maintainer="Kong <support@konghq.com>"

COPY --from=DOWNLOADER /tmp/kong.rpm /tmp/kong.rpm

RUN yum install -y -q unzip \
	&& yum clean all -q \
	&& rm -fr /var/cache/yum/* /tmp/yum_save*.yumtx /root/.pki

RUN useradd kong \
	&& mkdir -p "/usr/local/kong" \
	&& yum install -y /tmp/kong.rpm \
	&& yum clean all \
	&& rm /tmp/kong.rpm \
	&& chown -R kong:0 /usr/local/kong \
	&& chmod -R g=u /usr/local/kong

USER kong

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGQUIT

CMD ["kong", "docker-start"]
