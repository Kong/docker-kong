# DO NOT update KONG_BUILD_TOOLS manually - it's set by update.sh
# to ensure same version is used here and in the respective kong version
KONG_BUILD_TOOLS?=4.25.3
PACKAGE?=apk
BASE?=alpine

DOCKER_TAG_PREFIX?=kong

RHEL_REGISTRY?=scan.connect.redhat.com
RHEL_REGISTRY_REPO?=$(RHEL_REGISTRY)/ospid-dd198cd0-ed8b-41bd-9c18-65fd85059d31/kong

build: ASSET_LOCATION?=ce
build: DOCKER_TAG?=$(DOCKER_TAG_PREFIX)-$(BASE)
build:
	docker build --no-cache --build-arg ASSET=$(ASSET_LOCATION) -t $(DOCKER_TAG) $(BASE)/

build_v2: ASSET_LOCATION?=remote
build_v2: DOCKER_TAG?=$(DOCKER_TAG_PREFIX)-$(PACKAGE)
build_v2:
	docker build --no-cache --build-arg ASSET=$(ASSET_LOCATION) -t $(DOCKER_TAG) -f Dockerfile.$(PACKAGE) .

.PHONY: test


test: KONG_DOCKER_TAG?=$(DOCKER_TAG)
test:
	if cd kong-build-tools; \
	then git pull; \
	else git clone https://github.com/Kong/kong-build-tools.git; fi
	cd kong-build-tools && git reset --hard $(KONG_BUILD_TOOLS)
	BASE=$(BASE) ./tests/test.sh --suite "Docker-Kong test suite"

release-rhel: build
	echo '$(RHEL_REGISTRY_KEY)' \
		| docker login -u unused $(RHEL_REGISTRY) --password-stdin
	docker tag kong-rhel $(RHEL_REGISTRY_REPO)/kong:$$TAG
	docker push $(RHEL_REGISTRY_REPO)/kong:$$TAG
	docker tag kong-rhel-minimal $(RHEL_REGISTRY_REPO)/kong:$$TAG-minimal
	docker push $(RHEL_REGISTRY_REPO)/kong:$$TAG-minimal

