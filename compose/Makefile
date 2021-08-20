kong-postgres:
	COMPOSE_PROFILES=database docker-compose up -d

kong-dbless:
	KONG_DATABASE=off docker-compose up -d

clean:
	docker-compose kill
	docker-compose rm -f
