# docker-node

[![CircleCI](https://circleci.com/gh/cubyn/docker-node/tree/master.svg?style=svg)](https://circleci.com/gh/cubyn/docker-node/tree/master)

Cubyn Docker container for Node.js and Yarn.
Based on [mhart/alpine-node](https://github.com/mhart/alpine-node).

## Usage

### Manual

To push images, Docker CLI must be logged to Cubyn Docker account

```sh
# Building all images in local
make build
# Tagging all image versions in local
make tag
# Pushing all image versions to Docker Hub
make push

# Or all commands in one
make
```

### Automatic

When a new configuration is push into `master` branch, the CI push the images to Docker Hub.

## Build on a new Node.js version

Update `NODE_VERSION` in `Makefile` to the required SemVer tag
[Availables tags](https://hub.docker.com/_/node):

```Makefile
# Makefile
NODE_VERSION=13.12.0
```

If the new Node.js version is a major one, add configuration in `.circleci/config.yml`:

```yml
version: 2
jobs:
  test:

  # ...

  build_[THE-MAJOR-NUMBER]:
    docker:
      - image: circleci/buildpack-deps:bionic-scm
    steps:
      - checkout
      - setup_remote_docker
      - run:
          name: build and push docker images
          command: |
            MAJOR=$(echo ${NODE_VERSION} | cut -d '.' -f1)
            MINOR=$(echo ${NODE_VERSION} | cut -d '.' -f2)
            docker login -u $DOCKER_BUILD_USER -p $DOCKER_BUILD_PASS
            docker build -t ${DK_IMAGE}:${NODE_VERSION} --build-arg SRC_TAG=${NODE_VERSION}-alpine --target base generic
            docker build -t ${DK_IMAGE}:ci-${NODE_VERSION} --build-arg SRC_TAG=${NODE_VERSION}-alpine --target ci generic
            docker build -t ${DK_IMAGE}:wkhtml-${NODE_VERSION} --build-arg SRC_TAG=${NODE_VERSION}-alpine --target wkhtmltopdf generic
            docker build -t ${DK_IMAGE}:wkhtml-ci-${NODE_VERSION} --build-arg SRC_TAG=${NODE_VERSION}-alpine --target wkhtmltopdf_ci generic
            docker tag ${DK_IMAGE}:${NODE_VERSION} ${DK_IMAGE}:${MAJOR}.${MINOR}
            docker tag ${DK_IMAGE}:${NODE_VERSION} ${DK_IMAGE}:${MAJOR}
            docker tag ${DK_IMAGE}:ci-${NODE_VERSION} ${DK_IMAGE}:ci-${MAJOR}.${MINOR}
            docker tag ${DK_IMAGE}:ci-${NODE_VERSION} ${DK_IMAGE}:ci-${MAJOR}
            docker tag ${DK_IMAGE}:wkhtml-${NODE_VERSION} ${DK_IMAGE}:wkhtml-${MAJOR}.${MINOR}
            docker tag ${DK_IMAGE}:wkhtml-${NODE_VERSION} ${DK_IMAGE}:wkhtml-${MAJOR}
            docker tag ${DK_IMAGE}:wkhtml-ci-${NODE_VERSION} ${DK_IMAGE}:wkhtml-ci-${MAJOR}.${MINOR}
            docker tag ${DK_IMAGE}:wkhtml-ci-${NODE_VERSION} ${DK_IMAGE}:wkhtml-ci-${MAJOR}
            docker push ${DK_IMAGE}:${NODE_VERSION}
            docker push ${DK_IMAGE}:${MAJOR}.${MINOR}
            docker push ${DK_IMAGE}:${MAJOR}
            docker push ${DK_IMAGE}:ci-${NODE_VERSION}
            docker push ${DK_IMAGE}:ci-${MAJOR}.${MINOR}
            docker push ${DK_IMAGE}:ci-${MAJOR}
            docker push ${DK_IMAGE}:wkhtml-${NODE_VERSION}
            docker push ${DK_IMAGE}:wkhtml-${MAJOR}.${MINOR}
            docker push ${DK_IMAGE}:wkhtml-${MAJOR}
            docker push ${DK_IMAGE}:wkhtml-ci-${NODE_VERSION}
            docker push ${DK_IMAGE}:wkhtml-ci-${MAJOR}.${MINOR}
            docker push ${DK_IMAGE}:wkhtml-ci-${MAJOR}
            if [ "$LATEST_VERSION" == "true" ]; then
              docker tag ${DK_IMAGE}:${NODE_VERSION} ${DK_IMAGE}:latest
              docker tag ${DK_IMAGE}:ci-${NODE_VERSION} ${DK_IMAGE}:ci-latest
              docker tag ${DK_IMAGE}:wkhtml-${NODE_VERSION} ${DK_IMAGE}:wkhtml-latest
              docker tag ${DK_IMAGE}:wkhtml-ci-${NODE_VERSION} ${DK_IMAGE}:wkhtml-ci-latest
              docker push ${DK_IMAGE}:latest
              docker push ${DK_IMAGE}:ci-latest
              docker push ${DK_IMAGE}:wkhtml-latest
              docker push ${DK_IMAGE}:wkhtml-ci-latest
            fi
            docker images
    environment:
      DK_IMAGE: "cubyn/node"
      NODE_VERSION: "[THE-MAJOR-NUMBER]"
      LATEST_VERSION: "false"

workflows:
  version: 2

  # ...

  "node-[THE-MAJOR-NUMBER]":
    jobs:
      - test
      - build_[THE-MAJOR-NUMBER]:
          context: cubyn_hub_docker
          requires:
            - test
          filters:
            branches:
              only: master
```

### Specifics images

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
