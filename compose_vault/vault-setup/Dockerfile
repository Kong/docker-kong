ARG VAULT_VERSION=1.3.4

FROM vault:${VAULT_VERSION}

RUN apk add --no-cache bash curl postgresql-client

COPY db_creds.tpl /tmp/db_creds.tpl
COPY entrypoint.sh /entrypoint.sh
RUN chmod 777 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
