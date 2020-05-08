ARG KONG_VERSION=2.0

FROM kong:${KONG_VERSION}

USER root

RUN apk add unzip wget bash \
    && wget https://releases.hashicorp.com/consul-template/0.24.1/consul-template_0.24.1_linux_amd64.zip \
    && unzip consul-template_0.24.1_linux_amd64.zip \
    && mv consul-template /usr/local/bin/consul-template

COPY consul-template.conf /tmp/consul-template.conf

RUN cat /tmp/consul-template.conf >> /etc/kong/kong.conf.default \
    && cp /etc/kong/kong.conf.default /etc/kong/kong.conf.template \
    && chown -R kong:0 /etc/kong/ \
    && chown -R kong:0 /usr/local/bin/consul-template

USER kong

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8000 8443 8001 8444
