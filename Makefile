KONG_BUILD_TOOLS?=2.0.5
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
