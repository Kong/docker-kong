FROM heitorcarneiro/kong:2.6.0-alpine

ENV KONG_DATABASE="off"
ENV KONG_PROXY_LISTEN="0.0.0.0:8080"
ENV KONG_ADMIN_LISTEN="0.0.0.0:8001"
ENV KONG_ADMIN_ACCESS_LOG="/dev/stdout"
ENV KONG_ADMIN_ERROR_LOG="/dev/stderr"
ENV KONG_PROXY_ACCESS_LOG="/dev/stdout"
ENV KONG_PROXY_ERROR_LOG="/dev/stderr"
ENV KONG_DECLARATIVE_CONFIG="/opt/kong/kong.yaml"
ENV KONG_PLUGINS="bundled,oidc,circuit-breaker,scalable-rate-limiter,jwt-claims-headers"

USER root
RUN mkdir -p /opt/kong
COPY kong.yaml /opt/kong/kong.yaml
RUN chown -R kong:kong /opt/kong

EXPOSE 8080

HEALTHCHECK --interval=10s --timeout=10s --retries=10 CMD kong health || exit 1

STOPSIGNAL SIGTERM

USER kong
