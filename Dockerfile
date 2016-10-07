FROM centos:7
MAINTAINER Marco Palladino, marco@mashape.com

ENV KONG_VERSION 0.7.0
ENV CASSANDRA_HOST cassandra
ENV CASSANDRA_PORT 9042

RUN yum install -y epel-release && \
    yum install -y http://dl.fedoraproject.org/pub/epel/7/x86_64/t/tcping-1.3.5-13.el7.x86_64.rpm && \
    yum install -y https://github.com/Mashape/kong/releases/download/$KONG_VERSION/kong-$KONG_VERSION.el7.noarch.rpm && \
    yum clean all

RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64 && \
    chmod +x /usr/local/bin/dumb-init

COPY config.docker/kong.yml /etc/kong/kong.yml

ENTRYPOINT echo "Waiting for cassandra on host ${CASSANDRA_HOST} and port ${CASSANDRA_PORT}..." && \
           while ! tcping -t 1 ${CASSANDRA_HOST} ${CASSANDRA_PORT} ; do sleep 0.3; done && \
           echo "Cassandra is ready! Launching Kong..." && \
           sed -i s#cassandra:9042#${CASSANDRA_HOST}:${CASSANDRA_PORT}#g /etc/kong/kong.yml && \
           kong start

EXPOSE 8000 8443 8001 7946
CMD ["kong", "start"]