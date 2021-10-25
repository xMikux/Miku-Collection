FROM arm64v8/golang:1.17-alpine AS Builder

RUN set -xe; \
    apk add git; \
    go get github.com/path-network/go-mmproxy

WORKDIR /gommproxy
COPY entrypoint.sh /gommproxy/

RUN set -xe; \
    chmod +x entrypoint.sh

LABEL org.opencontainers.image.source https://github.com/xMikux/Miku-Collection

ENTRYPOINT [ "./entrypoint.sh" ]
