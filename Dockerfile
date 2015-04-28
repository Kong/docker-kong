FROM centos:7
MAINTAINER Marco Palladino, marco@mashape.com

# installing dnsmasq
RUN yum -y install dnsmasq wget

# configuring dnsmasq
RUN echo -e "user=root\nno-resolv\nserver=8.8.8.8" >> /etc/dnsmasq.conf

# download Kong
RUN wget https://github.com/Mashape/kong/releases/download/0.2.0-2/kong-0.2.0_2.el7.noarch.rpm && yum install -y kong-0.2.0_2.el7.noarch.rpm

# copy configuration files
ADD config.docker/* /etc/kong/

# run Kong
CMD dnsmasq && kong start

EXPOSE 8000 8001
