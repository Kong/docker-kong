build:
	docker build -t heitorcarneiro/kong-test .

up-it:
	docker run -it --rm --name kong -p "8080:8080" heitorcarneiro/kong-test

up:
	docker run -d --rm --name kong -p "8080:8080" heitorcarneiro/kong-test

up-stats:
	docker run -d --rm --name monitor --memory=64m --memory-swap=64m -p 8081:8080 -v /var/run/docker.sock:/var/run/docker.sock vasilvasilev97/docker-stats-monitor

down:
	docker kill $(docker ps -q)
	docker container prune -f

restart:
	docker restart kong

req-cache:
	curl -i -X GET http://localhost:8080/search-ip/json/187.110.146.115

req-jwt:
	curl -i -X GET http://localhost:8001/consumers/mock-user/jwt

req-unauthorized:
	curl -i -X GET http://localhost:8080/request

req-auth:
	curl -i -X GET http://localhost:8080/request -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJhMzZjMzA0OWIzNjI0OWEzYzlmODg5MWNiMTI3MjQzYyIsImlhdCI6MTYzMzgxMzM4NCwiZXhwIjoxNjMzODE1NDI5LCJhdWQiOiJ3d3cuZXhhbXBsZS5jb20iLCJzdWIiOiJqcm9ja2V0QGV4YW1wbGUuY29tIiwiR2l2ZW5OYW1lIjoiSm9obm55IiwiU3VybmFtZSI6IlJvY2tldCIsIkVtYWlsIjoianJvY2tldEBleGFtcGxlLmNvbSIsIlJvbGUiOlsiTWFuYWdlciIsIlByb2plY3QgQWRtaW5pc3RyYXRvciJdfQ.ol77eZzI9Apuuf-NC6bOqjCiJdbJqUnPb3nGmhJsDnQ'

# https://k6.io/blog/how-to-generate-a-constant-request-rate-with-the-new-scenarios-api/
performance-test:
	k6 run performance-test.js
