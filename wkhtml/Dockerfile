# For DYNAMIC (native modules in app) builds and CI builds
# tags are cubyn/node:wkhtml-dynamic-{version} for DYNAMIC
# tags are cubyn/node:wkhtml-ci-{version} for CI
FROM mhart/alpine-node:8.6

# install yarn
RUN apk update \
  && apk add --no-cache curl bash binutils tar \
  && rm -rf /var/cache/apk/* \
  && curl -o- -L https://yarnpkg.com/install.sh | bash \
  && ln -s /root/.yarn/bin/yarn /usr/bin/yarn \
  && rm -rf /tmp \
  && mkdir /tmp \
  && apk del curl tar binutils \
  && npm install -g node-gyp

RUN apk add --update --no-cache \
  xvfb \
  ttf-dejavu freetype-dev libjpeg-turbo-dev ttf-droid ttf-freefont ttf-liberation ttf-ubuntu-font-family cairo-dev \
  libgcc libstdc++ libx11 glib libxrender libxext libintl \
  libcrypto1.0 libssl1.0

# wkhtml is not on public alpine repo
COPY lib/wkhtmltopdf /usr/bin/wkhtmltopdf-origin

# Wrap wkhtmltopdf with xvfb
# See reference https://hub.docker.com/r/loicmahieu/alpine-wkhtmltopdf/~/dockerfile/
RUN  echo $'#!/usr/bin/env sh\n\
  export RAND_SCREEN=$RANDOM\n\
  Xvfb :$RAND_SCREEN -screen 0 1024x768x24 -ac +extension GLX +render -noreset & export APP_PID=$!\n\
  DISPLAY=:$RAND_SCREEN.0 wkhtmltopdf-origin $@ \n\
  kill $APP_PID' > /usr/bin/wkhtmltopdf && \
  chmod +x /usr/bin/wkhtmltopdf

RUN apk --no-cache add ca-certificates wget && \
  wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
  wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.25-r0/glibc-2.25-r0.apk && \
  wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.25-r0/glibc-bin-2.25-r0.apk && \
  wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.25-r0/glibc-i18n-2.25-r0.apk && \
  apk add glibc-bin-2.25-r0.apk glibc-i18n-2.25-r0.apk glibc-2.25-r0.apk \
  && apk del wget

# Iterate through all locale and install it
# Note that locale -a is not available in alpine linux, use `/usr/glibc-compat/bin/locale -a` instead
COPY ./locale.md locale.md
RUN cat locale.md | xargs -i /usr/glibc-compat/bin/localedef -i {} -f UTF-8 {}.UTF-8

# For CI Builds ONLY
# tags are cubyn/node:ci-{version}
# RUN apk update && \
#   apk add --no-cache python make g++ libexecinfo-dev curl mysql-client
