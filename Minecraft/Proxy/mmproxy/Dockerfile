FROM arm64v8/golang:1.17-alpine AS Builder

RUN set -xe; \
    apk add git; \
    go get github.com/path-network/go-mmproxy; \
    ls -lh /go/bin/go-mmproxy

FROM arm64v8/debian:bullseye-slim

WORKDIR /gommproxy
COPY entrypoint.sh /gommproxy/
COPY --from=Builder /go/bin/go-mmproxy /usr/bin/go-mmproxy

RUN set -xe; \
    apt-get update; \
    apt-get install -y iproute2 --no-install-recommends; \
    rm -rf /var/lib/apt/lists/*; \
    chmod +x entrypoint.sh; \
    ls -lh /usr/bin/go-mmproxy

LABEL org.opencontainers.image.source https://github.com/xMikux/Miku-Collection

ENTRYPOINT [ "./entrypoint.sh" ]
