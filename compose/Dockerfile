FROM postgres:9.5

COPY ["./server.crt", "./server.key", "/var/lib/postgresql/"]

RUN chown -R postgres /var/lib/postgresql/server.* \
    && chmod 600 -R /var/lib/postgresql/server.*