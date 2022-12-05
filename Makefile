# DO NOT update KONG_BUILD_TOOLS manually - it's set by update.sh
# to ensure same version is used here and in the respective kong version
KONG_BUILD_TOOLS?=4.33.19

PACKAGE?=apk
BASE?=alpine

DOCKER_TAG_PREFIX?=kong

KONG_VERSION?=
KONG_SHA256?=

# these two flags cannot be specified in this makefile <at all> if the default
# values from the Dockerfiles are desired
#
# this way, the build-arg flag variables are empty (preventing a flag from
# being passed to docker at all) if the parent VARs are unset
ifeq ($(strip $(KONG_VERSION)),)
KONG_VERSION_FLAG:=
else
KONG_VERSION_FLAG:=--build-arg KONG_VERSION=$(KONG_VERSION)
endif

ifeq ($(strip $(KONG_SHA256)),)
KONG_SHA256_FLAG:=
else
KONG_SHA256_FLAG:=--build-arg KONG_SHA256=$(KONG_SHA256)
endif

RHEL_REGISTRY_KEY?=
RHEL_REGISTRY?=scan.connect.redhat.com
RHEL_PID?=
RHEL_REGISTRY_REPO?=$(RHEL_REGISTRY)/$(RHEL_PID)/kong

# search for "build_v2" in the invocation make goals and set tags accordingly
ifneq ($(findstring build_v2,$(MAKECMDGOALS)),)
	DOCKER_TAG?=$(DOCKER_TAG_PREFIX)-$(PACKAGE)
else
	DOCKER_TAG?=$(DOCKER_TAG_PREFIX)-$(BASE)
endif

build: ASSET_LOCATION?=ce
build:
	docker build \
		--no-cache \
		--build-arg ASSET=$(ASSET_LOCATION) \
		$(KONG_VERSION_FLAG) \
		$(KONG_SHA256_FLAG) \
		-t $(DOCKER_TAG) \
		$(BASE)/

# (yzl, 14 June 2022) Should you change this substantially, please update build_your_own_images.md.
build_v2: ASSET_LOCATION?=remote
build_v2:
	docker image inspect -f='{{.Id}}' $(DOCKER_TAG) || \
	docker build \
		--no-cache \
		--build-arg ASSET=$(ASSET_LOCATION) \
		$(KONG_VERSION_FLAG) \
		$(KONG_SHA256_FLAG) \
		-t $(DOCKER_TAG) \
		-f Dockerfile.$(PACKAGE) \
		.

.PHONY: test

test: KONG_DOCKER_TAG?=$(DOCKER_TAG)
test:
	if cd kong-build-tools; \
	then git pull; \
	else git clone https://github.com/Kong/kong-build-tools.git; fi
	cd kong-build-tools && git reset --hard $(KONG_BUILD_TOOLS)
	BASE=$(BASE) ./tests/test.sh --suite "Docker-Kong test suite"

release-rhel: build_v2
	$(MAKE) PACKAGE=rpm build_v2
	@if \
		test -z '$(KONG_VERSION)' || \
		test -z '$(RHEL_PID)' || \
		test -z '$(RHEL_REGISTRY_KEY)' \
	; then \
		echo 'one of $$KONG_VERSION, $$RHEL_PID, $$RHEL_REGISTRY_KEY unset'; \
		exit 2; \
	fi
	@echo '$(RHEL_REGISTRY_KEY)' \
		| docker login -u unused $(RHEL_REGISTRY) --password-stdin
	docker tag $(DOCKER_TAG) $(RHEL_REGISTRY_REPO):$(KONG_VERSION)
	docker push $(RHEL_REGISTRY_REPO):$(KONG_VERSION)

