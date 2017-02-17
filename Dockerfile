FROM mhart/alpine-node:base-7
#FROM mhart/alpine-node:base-7.5

RUN apk update \
  && apk add --no-cache curl bash binutils tar \
  && rm -rf /var/cache/apk/* \
  && curl -o- -L https://yarnpkg.com/install.sh | bash \
  && ln -s /root/.yarn/bin/yarn /usr/bin/yarn \
  && rm -rf /tmp \
  && apk del curl tar binutils
