FROM registry.access.redhat.com/ubi7/ubi

MAINTAINER Kong

ENV KONG_VERSION 1.2.0

LABEL name="Kong" \
      vendor="Kong" \
      version="${KONG_VERSION}" \
      release="1" \
      url="https://konghq.com" \
      summary="Next-Generation API Platform for Modern Architectures" \
      description="Next-Generation API Platform for Modern Architectures"

COPY LICENSE /licenses/

RUN yum install -y wget https://bintray.com/kong/kong-rpm/download_file?file_path=rhel/7/kong-$KONG_VERSION.rhel7.noarch.rpm && \
    yum clean all && \
    # OpenShift specific. OpenShift runs containers using an arbitrarily assigned user ID.
    # This user doesn't have access to change file permissions during runtime, they have to be changed during image building.
    # https://docs.okd.io/latest/creating_images/guidelines.html#use-uid
    mkdir -p "/usr/local/kong" && \
    chgrp -R 0 "/usr/local/kong" && \
    chmod -R g=u "/usr/local/kong"

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGQUIT

CMD ["kong", "docker-start"]
