# set default shell
SHELL := $(shell which bash)
ENV = /usr/bin/env
# default shell options
.SHELLFLAGS = -c

# always use a full semver version
NODE_VERSION=10.15.2
LATEST_VERSION=false
BUILD_DIR=generic
STAGE = base

DK_IMAGE=cubyn/node

DK_SRC_TAG=$(NODE_VERSION)-alpine
DK_TAG=$(NODE_VERSION)

DK_NEW_TAG=latest

TAG_PREFIX=
TAG_SUFFIX=

MAJOR=$(shell echo $(NODE_VERSION) | cut -d '.' -f1)
MINOR=$(shell echo $(NODE_VERSION) | cut -d '.' -f2)
PATCH=$(shell echo $(NODE_VERSION) | cut -d '.' -f3)

.SILENT: ;               # no need for @
.ONESHELL: ;             # recipes execute in same shell
.NOTPARALLEL: ;          # wait for this target to finish
.EXPORT_ALL_VARIABLES: ; # send all vars to shell

default: all

all:
	$(MAKE) check
	$(MAKE) build
	$(MAKE) tag
	$(MAKE) push
.PHONY: all

# install local git hooks
githooks:
	# git config core.hooksPath .githooks
	find .git/hooks -type l -exec rm -v {} \;
	find .githooks -maxdepth 1 -type f -exec ln -v -sf ../../{} .git/hooks/ \;
	chmod a+x .git/hooks/*
.PHONY: githooks

check:
	docker run --rm  -w /src -v "$$PWD:/src" hadolint/hadolint:latest hadolint $(BUILD_DIR)/Dockerfile
.PHONY: check

_build:
	echo "Building $(DK_IMAGE):$(TAG_PREFIX)$(DK_TAG)$(TAG_SUFFIX) (stage $(STAGE)) from parent image node:$(DK_SRC_TAG)"; \
	docker build -t $(DK_IMAGE):$(TAG_PREFIX)$(DK_TAG)$(TAG_SUFFIX) \
		--build-arg SRC_TAG=$(DK_SRC_TAG) \
		--target $(STAGE) \
		$(BUILD_DIR) ;
.PHONY: _build

_tag:
	echo "Tagging image $(DK_IMAGE):$(TAG_PREFIX)$(DK_TAG)$(TAG_SUFFIX) to $(DK_IMAGE):$(TAG_PREFIX)$(DK_NEW_TAG)$(TAG_SUFFIX)"
	docker tag $(DK_IMAGE):$(TAG_PREFIX)$(DK_TAG)$(TAG_SUFFIX) $(DK_IMAGE):$(TAG_PREFIX)$(DK_NEW_TAG)$(TAG_SUFFIX)
.PHONY: _tag

_push:
	echo "Pushing image $(TAG_PREFIX)$(DK_TAG)$(TAG_SUFFIX)"
	docker push $(DK_IMAGE):$(TAG_PREFIX)$(DK_TAG)$(TAG_SUFFIX)
.PHONY: _push

build:
	$(MAKE) _build DK_TAG=$(DK_TAG)
	$(MAKE) _build DK_TAG=$(DK_TAG) STAGE=ci TAG_PREFIX="ci-"
.PHONY: build

tag:
	$(MAKE) tags-latest
	$(MAKE) tags-minor
	$(MAKE) tags-major
.PHONY: tag

push:
	$(MAKE) _push DK_TAG=$(NODE_VERSION) ;\
	$(MAKE) _push DK_TAG=$(NODE_VERSION) TAG_PREFIX="ci-" ;\
	$(MAKE) _push DK_TAG=$(MAJOR).$(MINOR) ;\
	$(MAKE) _push DK_TAG=$(MAJOR).$(MINOR) TAG_PREFIX="ci-" ;\
	$(MAKE) _push DK_TAG=$(MAJOR) ;\
	$(MAKE) _push DK_TAG=$(MAJOR) TAG_PREFIX="ci-" ;\
	if [ "$(LATEST_VERSION)" == "true" ]; then  \
		$(MAKE) _push DK_TAG=latest ;\
		$(MAKE) _push DK_TAG=latest TAG_PREFIX="ci-" ;\
	fi
.PHONY: push

tags-latest:
	if [ "$(LATEST_VERSION)" == "true" ]; then  \
		$(MAKE) _tag DK_TAG=$(NODE_VERSION) DK_NEW_TAG=latest ;\
		$(MAKE) _tag DK_TAG=ci-$(NODE_VERSION) DK_NEW_TAG=ci-latest ;\
	fi
.PHONY: tags-latest

tags-minor:
	$(MAKE) _tag DK_TAG=$(NODE_VERSION) DK_NEW_TAG=$(MAJOR).$(MINOR)
	$(MAKE) _tag DK_TAG=ci-$(NODE_VERSION) DK_NEW_TAG=ci-$(MAJOR).$(MINOR)
.PHONY: tags-minor

tags-major:
	$(MAKE) _tag DK_TAG=$(NODE_VERSION) DK_NEW_TAG=$(MAJOR)
	$(MAKE) _tag DK_TAG=ci-$(NODE_VERSION) DK_NEW_TAG=ci-$(MAJOR)
.PHONY: tags-major
