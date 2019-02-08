# For REGULAR builds
# tags are cubyn/node:{version}
ARG SRC_TAG=10.15-alpine
FROM node:${SRC_TAG} as base

RUN apk update && apk add --no-cache \
    make \
    curl \
    mysql-client

# For DYNAMIC (native modules in app) builds and CI builds
# tags are cubyn/node:dynamic-{version} for DYNAMIC

# For CI Builds ONLY
# tags are cubyn/node:ci-{version}
FROM base as ci

RUN apk update && apk add --no-cache \
   python \
   g++ \
   libexecinfo-dev
