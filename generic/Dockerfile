# For REGULAR builds
# tags are cubyn/node:{version}
ARG SRC_TAG=10.15-alpine
ARG WKHTMLTOPDF_TAG=0.12.5
FROM node:${SRC_TAG} as base

RUN apk update && apk add --no-cache \
    make \
    curl \
    bash \
    mysql-client

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
    # Install microsoft fonts
    && update-ms-fonts \
    && fc-cache -f \
    # Clean up when done
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

RUN apk update && apk add --no-cache \
   python \
   g++ \
   libexecinfo-dev


FROM wkhtmltopdf as wkhtmltopdf_ci

RUN apk update && apk add --no-cache \
  python \
  g++ \
  libexecinfo-dev
