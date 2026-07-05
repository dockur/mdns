# syntax=docker/dockerfile:1

FROM alpine:3.14 AS builder

WORKDIR /build

RUN <<EOF
  set -eu

  apk update
  apk upgrade
  apk --no-cache add \
    musl-dev \
    gcc \
    cmake \
    make \
    libcap

  cmake -DCMAKE_BUILD_TYPE=release ..
  make VERBOSE=1 \
  make install DESTDIR=install
  setcap cap_net_raw+ep build/install/usr/local/bin/mdns-reflector

  rm -rf /tmp/* /var/cache/apk/*
EOF

FROM alpine:3.14

COPY --chmod=755 entrypoint.sh /usr/local/bin/
COPY --chmod=755 --from=builder /build/install/ /usr/local/bin/

CMD ["/usr/local/bin/entrypoint.sh"]

ENV INTERFACE1=""
ENV INTERFACE2=""

EXPOSE 5353/udp
