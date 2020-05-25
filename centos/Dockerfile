FROM centos:7
LABEL maintainer="Kong <support@konghq.com>"

ARG ASSET=ce
ENV ASSET $ASSET

COPY empty-kong.rpm /tmp/kong.rpm

ARG KONG_VERSION=2.0.4
ENV KONG_VERSION $KONG_VERSION

ARG KONG_SHA256="16a934a7bc2e182f00f03bd75b67f4bdb483150b3820d33cab9b0c95539dd353"
ENV KONG_SHA256 $KONG_SHA256

RUN set -ex; \
	if [ "$ASSET" = "ce" ] ; then \
		curl -fL "https://bintray.com/kong/kong-rpm/download_file?file_path=centos/7/kong-$KONG_VERSION.el7.amd64.rpm" -o /tmp/kong.rpm \
		&& echo "$KONG_SHA256  /tmp/kong.rpm" | sha256sum -c -; \
	fi; \
	yum install -y -q unzip shadow-utils git zlib zlib-devel \
	&& yum clean all -q \
	&& rm -fr /var/cache/yum/* /tmp/yum_save*.yumtx /root/.pki \
	&& useradd kong \
	&& mkdir -p "/usr/local/kong" \
	&& yum install -y /tmp/kong.rpm \
	&& yum clean all \
	&& rm /tmp/kong.rpm \
	&& chown -R kong:0 /usr/local/kong \
	&& chown kong:0 /usr/local/bin/kong \
	&& chmod -R g=u /usr/local/kong \
	&& kong version

COPY docker-entrypoint.sh /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGQUIT

CMD ["kong", "docker-start"]
