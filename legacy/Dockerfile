FROM centos:7
MAINTAINER Marco Palladino, marco@mashape.com

ENV KONG_VERSION 0.10.4

RUN yum install -y wget https://bintray.com/kong/kong-community-edition-rpm/download_file?file_path=dists%2Fkong-community-edition-$KONG_VERSION.el7.noarch.rpm && \
    yum clean all && \
    # OpenShift specific. OpenShift runs containers using an arbitrarily assigned user ID.
    # This user doesn't have access to change file permissions during runtime, they have to be changed during image building.
    # https://docs.okd.io/latest/creating_images/guidelines.html#use-uid
    mkdir -p "/usr/local/kong" && \
    chgrp -R 0 "/usr/local/kong" && \
    chmod -R g=u "/usr/local/kong"

RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64 && \
    chmod +x /usr/local/bin/dumb-init

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 7946
CMD ["kong", "start"]
