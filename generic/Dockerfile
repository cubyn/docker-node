# For REGULAR builds
# tags are cubyn/node:{version}
ARG SRC_TAG=lts-alpine3.9
ARG WKHTMLTOPDF_TAG=0.12.5
FROM node:${SRC_TAG} as base

RUN apk --update --no-cache add \
    make \
    curl \
    bash \
    mysql-client \
    openssl \
    ca-certificates \
    wget \
    && update-ca-certificates

ENV SHMIG_VERSION master
RUN wget -q -O /usr/local/bin/shmig https://raw.githubusercontent.com/mbucc/shmig/$SHMIG_VERSION/shmig && \
    chmod +x /usr/local/bin/shmig

ENV DOCKERIZE_VERSION v0.6.1
RUN wget -q https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

ENV GOSU_VERSION 1.11
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN set -eux; \
    apk add --no-cache --virtual .gosu-deps \
        dpkg \
    ; \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    wget -q -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
# clean up fetch dependencies
    apk del --no-network .gosu-deps; \
    chmod +x /usr/local/bin/gosu; \
# verify that the binary works
    gosu --version

# wkhtmltopdf image version
FROM cubyn/wkhtmltopdf:${WKHTMLTOPDF_TAG} as wkhtmltopdf_src
FROM base as wkhtmltopdf

RUN apk --update --no-cache add \
    ca-certificates \
    libgcc \
    libstdc++ \
    musl \
    qt5-qtbase \
    qt5-qtbase-x11 \
    qt5-qtsvg \
    qt5-qtwebkit \
    ttf-freefont \
    ttf-dejavu \
    ttf-droid \
    ttf-liberation \
    ttf-ubuntu-font-family \
    fontconfig \
    && apk add --no-cache --virtual .build-deps \
    msttcorefonts-installer \
    && update-ms-fonts \
    && fc-cache -f \
    && rm -rf /tmp/* \
    && apk del .build-deps

# Add openssl dependencies for wkhtmltopdf
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.8/main' >> /etc/apk/repositories && \
    apk add --no-cache libcrypto1.0 libssl1.0

# Add wkhtmltopdf
COPY --from=wkhtmltopdf_src /bin/wkhtmltopdf /bin/wkhtmltopdf

# For CI Builds ONLY
# tags are cubyn/node:ci-{version}
FROM base as ci
RUN apk add --no-cache -u musl-dev musl-utils musl && \
    apk add --no-cache \
    python3 \
    git \
    openssh-client \
    libexecinfo-dev \
    g++

FROM wkhtmltopdf as wkhtmltopdf_ci
RUN apk add --no-cache -u musl-dev musl-utils musl && \
    apk add --no-cache \
    python3 \
    git \
    openssh-client \
    libexecinfo-dev \
    g++
