up:
	docker-compose up -d

down:
	docker-compose kill
	docker-compose rm -f

restart:
	docker-compose restart kong

rcache:
	curl -i -X GET http://localhost:8080/search-ip/json/187.110.146.115

rjwt:
	curl -i -X GET http://localhost:8001/consumers/mock-user/jwt

rauth:
	curl -i -X GET http://localhost:8080/request -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJhMzZjMzA0OWIzNjI0OWEzYzlmODg5MWNiMTI3MjQzYyIsImlhdCI6MTYzMzgxMzM4NCwiZXhwIjoxNjMzODE1NDI5LCJhdWQiOiJ3d3cuZXhhbXBsZS5jb20iLCJzdWIiOiJqcm9ja2V0QGV4YW1wbGUuY29tIiwiR2l2ZW5OYW1lIjoiSm9obm55IiwiU3VybmFtZSI6IlJvY2tldCIsIkVtYWlsIjoianJvY2tldEBleGFtcGxlLmNvbSIsIlJvbGUiOlsiTWFuYWdlciIsIlByb2plY3QgQWRtaW5pc3RyYXRvciJdfQ.ol77eZzI9Apuuf-NC6bOqjCiJdbJqUnPb3nGmhJsDnQ'
