# docker-node

[![CircleCI](https://circleci.com/gh/cubyn/docker-node/tree/master.svg?style=svg)](https://circleci.com/gh/cubyn/docker-node/tree/master)

Build Docker container for Node.js and Yarn.
Based on [mhart/alpine-node](https://github.com/mhart/alpine-node).

## Usage

### Automatic (preferred)

When a new configuration is push into `master` branch, the CI push the images to Docker Hub.

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

## Build a new Node.js version

Update `NODE_VERSION` in `Makefile` to the required SemVer tag
[Availables tags](https://hub.docker.com/_/node):

```Makefile
# Makefile
NODE_VERSION=[THE-MAJOR-NUMBER]
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

### Images

See [Docker Hub](https://hub.docker.com/r/cubyn/node/tags/) for the complete list of available tags.
