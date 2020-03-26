KONG_BUILD_TOOLS?=2.4.2
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

release-rhel: build
	echo $$RHEL_REGISTRY_KEY | docker login -u unused scan.connect.redhat.com --password-stdin
	docker tag kong-rhel scan.connect.redhat.com/ospid-dd198cd0-ed8b-41bd-9c18-65fd85059d31/kong:$$TAG
	docker push scan.connect.redhat.com/ospid-dd198cd0-ed8b-41bd-9c18-65fd85059d31/kong:$$TAG

clean:
	-rm -rf kong-build-tools
	-rm -rf kong