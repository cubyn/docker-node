# docker-node

⚠️ **The current behaviour will re-build all images, possibly introducing errors** ⚠️

[![CircleCI](https://circleci.com/gh/cubyn/docker-node/tree/master.svg?style=svg)](https://circleci.com/gh/cubyn/docker-node/tree/master)

Build Docker images for Node.js and Yarn.

Each build will be done for:
- the exact `NODE_VERSION`
- the major and minor only
- the major only

Images that will be created:
- production
- CI
- wkhtml (PDF generation)
- CI wkhtml (PDF generation)

## Deprecated tools for Node.js < 16

Before Node.js 16, images use `generic/DockerfileLegacy`:
- Build image is based on `node:10.15-alpine`
- `circleci/buildpack-deps:bionic-scm`

For Node.js 16 and newer, images use `generic/Dockerfile`:
- Build image is based on `node:lts-alpine3.15`
- `cimg/base:2022.03` (https://hub.docker.com/r/cimg/base)

## Usage

### Automatic (preferred)

When a new configuration is push into `master` branch (or `node-X`), the CI push the images to Docker Hub.

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

Example for Node.js `16.14.2`

- Create a branch `node-16`
- Update `NODE_VERSION` in `Makefile` to the required SemVer tag ([availables tags](https://hub.docker.com/_/node)).

```Makefile
# Makefile
NODE_VERSION=16.14.2
```

- If the Node.js version is a major one, add configuration in `.circleci/config.yml`:

```yml
version: 2
jobs:
  test:

  # ...

  build_16:
    docker:
      - image: cimg/base:2022.03
    steps:
      - checkout
      - setup_remote_docker
      - run:
          name: Build and push Docker images
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
      NODE_VERSION: "16.14.2"
      LATEST_VERSION: "false"

workflows:
  version: 2

  # ...

  "node-16":
    jobs:
      - test
      - build_16:
          context: cubyn_hub_docker
          requires:
            - test
          filters:
            branches:
              only: node-16
```

## Images

See [Docker Hub](https://hub.docker.com/r/cubyn/node/tags/) for the complete list of available tags.
