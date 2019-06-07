FROM centos:7
LABEL maintainer="Kong Core Team <team-core@konghq.com>"

ENV KONG_VERSION 1.2.0

ARG SU_EXEC_VERSION=0.2
ARG SU_EXEC_URL="https://github.com/ncopa/su-exec/archive/v${SU_EXEC_VERSION}.tar.gz"

RUN yum install -y -q gcc make unzip \
	&& curl -sL "${SU_EXEC_URL}" | tar -C /tmp -zxf - \
	&& make -C "/tmp/su-exec-${SU_EXEC_VERSION}" \
	&& cp "/tmp/su-exec-${SU_EXEC_VERSION}/su-exec" /usr/bin \
	&& rm -fr "/tmp/su-exec-${SU_EXEC_VERSION}" \
	&& yum autoremove -y -q gcc make \
	&& yum clean all -q \
	&& rm -fr /var/cache/yum/* /tmp/yum_save*.yumtx /root/.pki

RUN useradd --uid 1337 kong \
	&& mkdir -p "/usr/local/kong" \
	&& yum install -y https://bintray.com/kong/kong-rpm/download_file?file_path=centos/7/kong-$KONG_VERSION.el7.noarch.rpm \
	&& yum clean all \
	&& chown -R kong:0 /usr/local/kong \
	&& chmod -R g=u /usr/local/kong

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGQUIT

CMD ["kong", "docker-start"]
