# syntax=docker/dockerfile:1

FROM alpine:latest AS builder

WORKDIR /build

RUN <<EOF
  set -eu

  apk update
  apk upgrade

  apk add --no-cache \
    ca-certificates \
    git \
    musl-dev \
    gcc \
    cmake \
    make

  git clone --depth=1 --branch main https://github.com/vfreex/mdns-reflector.git src

  cmake \
    -S src \
    -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr/local

  cmake --build build --verbose

  DESTDIR=/install cmake --install build
EOF

FROM alpine:latest

ARG VERSION_ARG="0.0"

RUN <<EOF
  set -eu

  apk update
  apk upgrade

  apk add --no-cache \
    bash \
    iproute2

  rm -rf /tmp/* /var/cache/apk/*

EOF

COPY --from=builder /install/ /
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

RUN <<EOF
  set -eu

  apk add --no-cache libcap

  # Grant raw socket capability needed for mDNS traffic
  setcap cap_net_raw+ep /usr/local/bin/mdns-reflector

  apk del libcap

  # Set version number
  echo "$VERSION_ARG" > /etc/version

EOF

ENV INTERFACES=""
ENV LOG_LEVEL="warning"

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
