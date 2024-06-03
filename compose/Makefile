# Determine whether to use 'docker-compose' or 'docker compose'
DOCKER_COMPOSE := $(shell command -v docker-compose || echo docker compose)

kong-postgres:
	@COMPOSE_PROFILES=database,traditional KONG_DATABASE=postgres $(DOCKER_COMPOSE) up -d

# Alias for kong-postgres
kong-traditional: kong-postgres

kong-dbless:
	@COMPOSE_PROFILES=traditional $(DOCKER_COMPOSE) up -d

kong-hybrid:
	@COMPOSE_PROFILES=hybrid,database KONG_DATABASE=postgres $(DOCKER_COMPOSE) up -d


clean:
	@$(DOCKER_COMPOSE) kill
	@$(DOCKER_COMPOSE) rm -f
