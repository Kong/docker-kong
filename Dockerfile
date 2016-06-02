FROM centos:7
MAINTAINER Marco Palladino, marco@mashape.com

ENV KONG_VERSION 0.8.3

RUN yum install -y https://github.com/Mashape/kong/releases/download/$KONG_VERSION/kong-$KONG_VERSION.el7.noarch.rpm && \
    yum clean all

COPY config.docker/kong.yml /etc/kong/

ADD setup.sh setup.sh
RUN chmod +x setup.sh

CMD ./setup.sh && kong start

EXPOSE 8000 8443 8001 7946
