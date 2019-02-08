# set default shell
SHELL := $(shell which bash)
ENV = /usr/bin/env
# default shell options
.SHELLFLAGS = -c

NODE_VERSION=10.15.1

BUILD_DIR=generic
STAGE = base

DK_IMAGE=cubyn/node

DK_SRC_TAG=$(NODE_VERSION)-alpine
DK_TAG=$(NODE_VERSION)

DK_NEW_TAG=latest

MAJOR=$(shell echo $(NODE_VERSION) | cut -d '.' -f1)
MINOR=$(shell echo $(NODE_VERSION) | cut -d '.' -f2)
PATCH=$(shell echo $(NODE_VERSION) | cut -d '.' -f3)

.SILENT: ;               # no need for @
.ONESHELL: ;             # recipes execute in same shell
.NOTPARALLEL: ;          # wait for this target to finish
.EXPORT_ALL_VARIABLES: ; # send all vars to shell

default: all

all:
	$(MAKE) build
	$(MAKE) tag
	$(MAKE) push
.PHONY: all

_build:
	echo "Building $(DK_IMAGE):$(DK_TAG) (stage $(STAGE)) from parent image node:$(DK_SRC_TAG)"; \
	docker build -t $(DK_IMAGE):$(DK_TAG) \
		--build-arg SRC_TAG=$(DK_SRC_TAG) \
		--target $(STAGE) \
		$(BUILD_DIR) ;
.PHONY: _build

_tag:
	echo "Tagging image $(DK_IMAGE):$(DK_TAG) to $(DK_IMAGE):$(DK_NEW_TAG)"
	docker tag $(DK_IMAGE):$(DK_TAG) $(DK_IMAGE):$(DK_NEW_TAG)
.PHONY: _tag

_push:
	echo "Pushing image $(DK_IMAGE):$(DK_TAG)"
	echo docker push $(DK_IMAGE):$(DK_TAG)
.PHONY: _push

build:
	$(MAKE) _build DK_TAG=$(DK_TAG)
	$(MAKE) _build STAGE=ci DK_TAG=ci-$(DK_TAG)
.PHONY: build

tag:
	$(MAKE) tags-latest
	$(MAKE) tags-minor
	$(MAKE) tags-major
.PHONY: tag

push:
	$(MAKE) _push DK_TAG=$(NODE_VERSION)
	$(MAKE) _push DK_TAG=ci-$(NODE_VERSION)
	$(MAKE) _push DK_TAG=latest
	$(MAKE) _push DK_TAG=ci-latest
	$(MAKE) _push DK_TAG=$(MAJOR).$(MINOR)
	$(MAKE) _push DK_TAG=ci-$(MAJOR).$(MINOR)
	$(MAKE) _push DK_TAG=$(MAJOR)
	$(MAKE) _push DK_TAG=ci-$(MAJOR)
.PHONY: push

tags-latest:
	$(MAKE) _tag DK_TAG=$(NODE_VERSION) DK_NEW_TAG=latest
	$(MAKE) _tag DK_TAG=ci-$(NODE_VERSION) DK_NEW_TAG=ci-latest
.PHONY: tags-latest

tags-minor:
	$(MAKE) _tag DK_TAG=$(NODE_VERSION) DK_NEW_TAG=$(MAJOR).$(MINOR)
	$(MAKE) _tag DK_TAG=ci-$(NODE_VERSION) DK_NEW_TAG=ci-$(MAJOR).$(MINOR)
.PHONY: tags-minor

tags-major:
	$(MAKE) _tag DK_TAG=$(NODE_VERSION) DK_NEW_TAG=$(MAJOR)
	$(MAKE) _tag DK_TAG=ci-$(NODE_VERSION) DK_NEW_TAG=ci-$(MAJOR)
.PHONY: tags-major
