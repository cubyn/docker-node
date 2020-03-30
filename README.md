# docker-node

[![CircleCI](https://circleci.com/gh/cubyn/docker-node/tree/master.svg?style=svg)](https://circleci.com/gh/cubyn/docker-node/tree/master)

Cubyn Docker container for Node.js and Yarn.
Based on [mhart/alpine-node](https://github.com/mhart/alpine-node).

## Usage

Docker CLI must be logged to Cubyn Docker account.

```sh
# Building all images
make build
# Tagging all image versions
make tag
# Pushing all image versions
make push

# Or all commands in one
make
```

## Build on a new Node.js version

Update ***NODE_VERSION*** in `Makefile` to the required SemVer tag.
[Availables tags](https://hub.docker.com/_/node):

```Makefile
# Makefile
NODE_VERSION=13.12.0
```

Rebuild and push to Docker Hub:

```sh
make
```

Availables Node.js tags:

Base image:

* `MAJOR`
* `MAJOR.MINOR`
* `MAJOR.MINOR.PATCH`
* `latest`

CI image:

* `ci-MAJOR`
* `ci-MAJOR.MINOR`
* `ci-MAJOR.MINOR.PATCH`
* `ci-latest`

See [Docker Hub](https://hub.docker.com/r/cubyn/node/tags/) for the complete list of available tags.

## Sample usage

```dockerfile
## If using compiled native modules (like iconv, bcrypt, etc.):
#FROM cubyn/node:dynamic-13.12.0
##
## else:
FROM cubyn/node:13.12.0

WORKDIR /app
ENV PWD /app

COPY package.json package.json
COPY yarn.lock yarn.lock

## if using private NPM token, it should be passed at build time with --build-args
#ARG NPM_TOKEN
#RUN echo "//registry.npmjs.org/:_authToken=$NPM_TOKEN" > ~/.npmrc
## don't forget to rm ~/.npmrc after module install for security concerns
## this should be merged into the RUN layer below so the .npmrc is not contained in any layer

## if using compiled native modules (like iconv, bcrypt, etc.)
#RUN apk add --no-cache python make g++ libexecinfo-dev && \
#    yarn install --production && \
#    apk del python make g++ libexecinfo-dev
## else
RUN yarn install --production

COPY src src

CMD ["node", "src"]
```
