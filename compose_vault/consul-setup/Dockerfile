ARG CONSUL_VERSION=1.7

FROM consul:${CONSUL_VERSION}

COPY entrypoint.sh /entrypoint.sh
COPY bootstrap.json /tmp/bootstrap.json
COPY nodes.json /tmp/nodes.json

ENTRYPOINT ["/entrypoint.sh"]
