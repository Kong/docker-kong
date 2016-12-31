FROM kong:0.9.6

COPY wait-for-postgres.sh /wait-for-postgres.sh
RUN chmod +x wait-for-postgres.sh
RUN yum update -y && yum install -y postgresql

CMD ./wait-for-postgres.sh $KONG_PG_HOST kong start
