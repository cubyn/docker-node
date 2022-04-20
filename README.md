# docker-node

[![CircleCI](https://circleci.com/gh/cubyn/docker-node/tree/master.svg?style=svg)](https://circleci.com/gh/cubyn/docker-node/tree/master)

Build Docker container for Node.js and Yarn.
Based on [mhart/alpine-node](https://github.com/mhart/alpine-node).

## Usage

### Automatic (preferred)

When a new configuration is pushed to `master` or to a branch with pattern `node-xx`, the CI pushes the images to
Docker Hub.

The convention is that `node-14` is configured to publish the latest version of Node 14.x, `node-16`
is configured to publish the latest version of Node 16.x, etc. and `master` is the current lts major version.

Some more changes may be pushed to each branch: if needing to deploy a fix to multiple major node
versions, you should cherry pick the patch on all branches you want to update.

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

Create a new branch `node-xx` for the new major version.

Update `NODE_VERSION` in `Makefile` to the required SemVer tag
[Availables tags](https://hub.docker.com/_/node):

```Makefile
# Makefile
NODE_VERSION=[MAJOR.MINOR.PATCH]
```

update `NODE_VERSION` in all jobs. For example:

```diff
  build-base:
    docker:
      - image: circleci/buildpack-deps:bionic-scm
    steps:
      - checkout
      - setup_remote_docker
      - run:
          name: build base image
          command: |
            MAJOR=$(echo ${NODE_VERSION} | cut -d '.' -f1)
            MINOR=$(echo ${NODE_VERSION} | cut -d '.' -f2)
            docker build -t ${DK_IMAGE}:${NODE_VERSION} --build-arg SRC_TAG=${NODE_VERSION}-alpine --target base generic
    environment:
      DK_IMAGE: "cubyn/node"
-      NODE_VERSION: "14.18.0"
+      NODE_VERSION: "16.14.2"
```

### Images

See [Docker Hub](https://hub.docker.com/r/cubyn/node/tags/) for the complete list of available tags.

## Known issue

If you push `NODE_VERSION=16.14.2` and then `NODE_VERSION=16.14.0`, image `cubyn/node:16` and
`cubyn/node:16.14` will have been overwritten and will point to `NODE_VERSION=16.14.0`, against what
could be reasonably assumed.

If we don't ever downgrade node version, we don't risk running into any issue; but if we have to fix
a previously published version, we need to be careful.
