# docker-node
Cubyn base docker container for Node.js, with yarn

The image is based on [mhart/alpine-node](https://github.com/mhart/alpine-node) and image size is 60MB (20 compressed)

## build
Tag can be `7`, `7.x` or `latest`. See [Docker Hub](https://hub.docker.com/r/cubyn/node/tags/) page for the list of available tags.

Un-comment or change the `FROM` statement in the Dockerfile before launching the build:

```sh
docker build -t cubyn/node:{tag} .
```

## sample usage

```dockerfile
## if using compiled native modules (like iconv, bcrypt, etc.)
#FROM cubyn/node:dynamic-7
## else
FROM cubyn/node:7

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