### JWT

https://konghq.com/blog/jwt-kong-gateway

https://jwt.io/

https://gist.github.com/martinheld/5b6591a1abd4c5ef844d6bd4f6eb1879

https://medium.com/@madhavi.ruwandika/how-to-set-up-kong-db-less-apis-authentication-with-jwt-token-validation-ff5f37fdbe4

```json
{
  "typ": "JWT",
  "alg": "HS256"
}
```

iss is the key in `curl -i -X GET http://localhost:8001/consumers/mock-user/jwt`

```json
{
  "iss": "a36c3049b36249a3c9f8891cb127243c"
}
```


Craft JWT using e.g. http://jwtbuilder.jamiekurtz.com/
- Issuer (key from above): a36c3049b36249a3c9f8891cb127243c
- Key (secret from above): e71829c351aa4242c2719cbfbe671c09


JWT:

```
eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJhMzZjMzA0OWIzNjI0OWEzYzlmODg5MWNiMTI3MjQzYyIsImlhdCI6MTYzMzgxMzM4NCwiZXhwIjoxNjMzODE1NDI5LCJhdWQiOiJ3d3cuZXhhbXBsZS5jb20iLCJzdWIiOiJqcm9ja2V0QGV4YW1wbGUuY29tIiwiR2l2ZW5OYW1lIjoiSm9obm55IiwiU3VybmFtZSI6IlJvY2tldCIsIkVtYWlsIjoianJvY2tldEBleGFtcGxlLmNvbSIsIlJvbGUiOlsiTWFuYWdlciIsIlByb2plY3QgQWRtaW5pc3RyYXRvciJdfQ.ol77eZzI9Apuuf-NC6bOqjCiJdbJqUnPb3nGmhJsDnQ
```

```
curl -i -X GET http://localhost:8080/request -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJhMzZjMzA0OWIzNjI0OWEzYzlmODg5MWNiMTI3MjQzYyIsImlhdCI6MTYzMzgxMzM4NCwiZXhwIjoxNjMzODE1NDI5LCJhdWQiOiJ3d3cuZXhhbXBsZS5jb20iLCJzdWIiOiJqcm9ja2V0QGV4YW1wbGUuY29tIiwiR2l2ZW5OYW1lIjoiSm9obm55IiwiU3VybmFtZSI6IlJvY2tldCIsIkVtYWlsIjoianJvY2tldEBleGFtcGxlLmNvbSIsIlJvbGUiOlsiTWFuYWdlciIsIlByb2plY3QgQWRtaW5pc3RyYXRvciJdfQ.ol77eZzI9Apuuf-NC6bOqjCiJdbJqUnPb3nGmhJsDnQ'
```
