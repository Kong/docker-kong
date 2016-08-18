FROM centos:7
MAINTAINER Marco Palladino, marco@mashape.com

ENV KONG_VERSION 0.9.0rc4

RUN yum install -y https://github.com/Mashape/kong/releases/download/$KONG_VERSION/kong-$KONG_VERSION.el7.noarch.rpm && \
    yum clean all

COPY kong.conf /etc/

EXPOSE 8000 8443 8001 7946

CMD ["kong", "start", "-c", "/etc/kong.conf"]
