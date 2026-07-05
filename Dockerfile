# syntax=docker/dockerfile:1

FROM alpine:latest AS builder

WORKDIR /build

RUN <<EOF
  set -eu

  apk add --no-cache \
    ca-certificates \
    git \
    musl-dev \
    gcc \
    cmake \
    make \
    libcap

  git clone --depth=1 --branch main https://github.com/vfreex/mdns-reflector.git src

  cmake \
    -S src \
    -B build \
    -DCMAKE_BUILD_TYPE=release \
    -DCMAKE_INSTALL_PREFIX=/usr/local

  cmake --build build --verbose

  DESTDIR=/install cmake --install build

  setcap cap_net_raw+ep /install/usr/local/bin/mdns-reflector
EOF

FROM alpine:latest

COPY --from=builder /install/ /
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

ENV INTERFACES=""

EXPOSE 5353/udp

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
