FROM centos:7
MAINTAINER Marco Palladino, marco@mashape.com

ENV KONG_VERSION 0.10.3

RUN yum install -y wget https://github.com/Mashape/kong/releases/download/$KONG_VERSION/kong-$KONG_VERSION.el7.noarch.rpm && \
    yum clean all

RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64 && \
    chmod +x /usr/local/bin/dumb-init

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

# The first kong container will have to run migrations on the database, so it will
# take a while for the port 8000 to be reachable. --start-period will help us delay
# the healthcheck failure
HEALTHCHECK --interval=5s --retries=10 --start-period=180s \
    CMD curl -I -s -L http://127.0.0.1:8000 || exit 1

EXPOSE 8000 8443 8001 7946
CMD ["kong", "start"]