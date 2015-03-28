# Kong
#
# VERSION       0.1.0beta-3

FROM centos:7
MAINTAINER Marco Palladino, marco@mashape.com

ENV KONG_VERSION 0.1.0beta_3

# installing dnsmasq
RUN yum -y install dnsmasq

# configuring dnsmasq
RUN echo -e "user=root\nno-resolv\nserver=8.8.8.8" >> /etc/dnsmasq.conf

# download Kong
RUN echo -e "[kong]\nname = Kong\nbaseurl = http://mashape-kong-yum-repo.s3-website-us-east-1.amazonaws.com/\$releasever/\$basearch\nenabled = 1\ngpgcheck = 0" > /etc/yum.repos.d/kong.repo

RUN yum -y install kong-$KONG_VERSION-1

# copy configuration files
ADD config.docker/* /etc/kong/

# run Kong
CMD dnsmasq && kong start

EXPOSE 8000 8001
