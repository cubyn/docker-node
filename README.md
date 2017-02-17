# docker-node
Cubyn base docker container for Node.js, with yarn

The image is based on [mhart/alpine-node](https://github.com/mhart/alpine-node) and image size is 60MB

## build
Tag can be `7`, `7.5` or `latest`.

Un-comment or change the `FROM` statement in the Dockerfile before launching the build:

```sh
docker build -t cubyn/node:{tag} .
```

## sample usage

```dockerfile
FROM cubyn/node:latest

COPY package.json package.json
COPY yarn.lock yarn.lock

RUN yarn install --production

COPY src src

ENTRYPOINT node --harmony-async-await src
```