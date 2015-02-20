# Kong
#
# VERSION       0.1-preview

# use the Openresty base image provided by Mashape
FROM mashape/docker-openresty
MAINTAINER Marco Palladino, marco@mashape.com

ENV KONG_VERSION 0.1-preview

# download Kong
RUN wget https://github.com/Mashape/kong/archive/$KONG_VERSION.tar.gz && tar xzf $KONG_VERSION.tar.gz

# moving kong to a default directory "kong"
RUN mv kong-$KONG_VERSION kong

# install Kong
RUN cd kong && make install

# copy configuration files
ADD config.docker/* kong/config.default/

# run Kong
CMD ["kong/bin/kong migrate && kong/bin/kong start"]

EXPOSE 8000 8001
