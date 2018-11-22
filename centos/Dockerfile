FROM centos:7
LABEL maintainer="Kong Core Team <team-core@konghq.com>"

ENV KONG_VERSION 1.0.0rc3

RUN yum install -y wget https://bintray.com/kong/kong-community-edition-rpm/download_file?file_path=centos/7/kong-community-edition-$KONG_VERSION.el7.noarch.rpm && \
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

STOPSIGNAL SIGTERM

CMD ["kong", "docker-start"]
