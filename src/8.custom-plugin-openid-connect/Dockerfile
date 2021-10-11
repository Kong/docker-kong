FROM kong:2.6.0-alpine

LABEL description="Alpine + Kong 2.6.0 + kong-oidc + kong-circuit-breaker + kong-scalable-rate-limiter + kong-plugin-jwt-claims-headers"

USER root
RUN apk update && apk add git unzip luarocks

# https://github.com/nokia/kong-oidc
RUN luarocks install --pin lua-resty-jwt 0.2.2-0
RUN luarocks install kong-oidc

# https://github.com/dream11/kong-circuit-breaker
RUN luarocks install kong-circuit-breaker

# https://github.com/dream11/kong-scalable-rate-limiter
RUN luarocks install scalable-rate-limiter

# https://github.com/wshirey/kong-plugin-jwt-claims-headers
RUN git clone https://github.com/wshirey/kong-plugin-jwt-claims-headers.git \
    && cd kong-plugin-jwt-claims-headers \
    && luarocks make

USER kong
