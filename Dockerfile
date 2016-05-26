FROM centos:7
MAINTAINER Marco Palladino, marco@mashape.com

ENV KONG_VERSION 0.8.2

RUN yum install -y epel-release && \
    yum install -y https://github.com/Mashape/kong/releases/download/$KONG_VERSION/kong-$KONG_VERSION.el7.noarch.rpm && \
    yum clean all

VOLUME ["/etc/kong/"]

COPY config.docker/kong.yml /etc/kong/kong.yml

ADD setup.sh setup.sh
RUN chmod +x setup.sh

CMD ./setup.sh && kong start

EXPOSE 8000 8443 8001 7946
