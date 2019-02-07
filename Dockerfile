# For REGULAR builds
# tags are cubyn/node:{version}
#FROM mhart/alpine-node:base-10.15

# For DYNAMIC (native modules in app) builds and CI builds
# tags are cubyn/node:dynamic-{version} for DYNAMIC
# tags are cubyn/node:ci-{version} for CI
FROM mhart/alpine-node:10.15

RUN apk update \
  && apk add --no-cache curl bash binutils tar \
  && rm -rf /var/cache/apk/* \
  && curl -o- -L https://yarnpkg.com/install.sh | bash \
  && ln -s /root/.yarn/bin/yarn /usr/bin/yarn \
  && rm -rf /tmp \
  && mkdir /tmp \
  && apk del curl tar binutils

# For CI Builds ONLY
# tags are cubyn/node:ci-{version}
RUN apk update && \
  apk add --no-cache python make g++ libexecinfo-dev make curl mysql-client
