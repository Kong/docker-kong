sync:
	deck sync

test:
	for number in 1 2 3 4 5 6 7 8 9 10 ; do \
			curl -i -X GET http://localhost:8000/mock/request ; \
	done

open:
	xdg-open http://localhost:8000/mock

request:
	curl -i -X GET http://localhost:8000/mock/request

request-auth:
	curl -i -X GET http://localhost:8000/mock/request?apikey=apikey

delete-cache:
	curl -i -X DELETE http://localhost:8001/proxy-cache
