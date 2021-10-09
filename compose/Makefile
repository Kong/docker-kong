kong-postgres:
	COMPOSE_PROFILES=database KONG_DATABASE=postgres docker-compose up -d

kong-dbless:
	docker-compose up -d

clean:
	docker-compose kill
	docker-compose rm -f

restart:
	docker-compose restart kong

request-auth:
	curl -i -X GET http://localhost:8000/request?apikey=mock-key

request-cache:
	curl -i -X GET http://localhost:8000/search-ip/json/187.110.146.115

gae-up:
	docker-compose -f gae.yml up -d

gae-clean:
	docker-compose -f gae.yml kill
	docker-compose -f gae.yml rm -f

gae-restart:
	docker-compose -f gae.yml restart kong

gae-request-auth:
	curl -i -X GET http://localhost:8080/request?apikey=mock-key

gae-request-cache:
	curl -i -X GET http://localhost:8080/search-ip/json/187.110.146.115
