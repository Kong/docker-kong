FROM centos:7
MAINTAINER Marco Palladino, marco@mashape.com

ENV KONG_VERSION 0.4.2

RUN yum -y install wget

RUN wget https://github.com/Mashape/kong/releases/download/$KONG_VERSION/kong-$KONG_VERSION.el7.noarch.rpm \
    && yum install -y kong-$KONG_VERSION.el7.noarch.rpm

RUN rm kong-$KONG_VERSION.el7.noarch.rpm

VOLUME ["/etc/kong/"]

COPY config.docker/kong.yml /etc/kong/kong.yml

CMD kong start

EXPOSE 8000 8001
