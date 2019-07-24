KONG_BUILD_TOOLS?=148c8b6ba88c35d79571f04f95a889a5f2f1377e
BASE?=centos

build:
	docker build -t kong-$(BASE) $(BASE)/

.PHONY: test
test:
	if cd kong-build-tools; \
	then git pull; \
	else git clone https://github.com/Kong/kong-build-tools.git; fi
	cd kong-build-tools && git reset --hard $(KONG_BUILD_TOOLS)
	BASE=$(BASE) ./tests.sh
