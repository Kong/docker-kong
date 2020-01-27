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
		community) VERSION='2.0.0'; KONG_SHA='0f1abc28d58e1092654ca9b58fbc725f560ca42ccab798cd55963ec5c5e0a317'; URL='https://bintray.com/kong/kong-rpm/download_file?file_path=rhel/7/kong-'$VERSION'.rhel7.amd64.rpm' ;; \
		enterprise) VERSION='1.3.0.1'; KONG_SHA='ad6216aaf476a2806b208ca8a175a6c96013a6149042a64de57f3d702de266ce'; URL='https://kong.bintray.com/kong-enterprise-edition-rpm/rhel/7/kong-enterprise-edition-'$VERSION'.rhel7.noarch.rpm' ;; \
	esac; \
	\
	curl -L -u$BINTRAY_USER:$BINTRAY_KEY "$URL" -o /tmp/kong.rpm; \
	echo "${KONG_SHA} /tmp/kong.rpm" | sha256sum -c -

FROM registry.access.redhat.com/ubi7/ubi

MAINTAINER Kong

LABEL name="Kong" \
      vendor="Kong" \
      version="${KONG_VERSION}" \
      release="1" \
      url="https://konghq.com" \
      summary="Next-Generation API Platform for Modern Architectures" \
      description="Next-Generation API Platform for Modern Architectures"

COPY --from=DOWNLOADER /tmp/kong.rpm /tmp/kong.rpm
COPY LICENSE /licenses/

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