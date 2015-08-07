FROM centos:7
MAINTAINER Marco Palladino, marco@mashape.com

RUN yum -y install wget

RUN wget http://downloadkong.org/el7.noarch.rpm -O kong.el7.noarch.rpm && yum install -y kong.el7.noarch.rpm

RUN rm kong.el7.noarch.rpm

VOLUME ["/etc/kong/"]

COPY config.docker/kong.yml /etc/kong/kong.yml

CMD kong start

EXPOSE 8000 8001
