FROM centos:7
MAINTAINER Marco Palladino, marco@mashape.com

ENV KONG_VERSION 0.6.0

RUN yum install -y epel-release
RUN yum install -y https://github.com/Mashape/kong/releases/download/$KONG_VERSION/kong-$KONG_VERSION.el7.noarch.rpm && \
    yum clean all

VOLUME ["/etc/kong/"]

COPY config.docker/kong.yml /etc/kong/kong.yml

CMD kong start && tail -f /usr/local/kong/logs/error.log

EXPOSE 8000 8443 8001 7946
