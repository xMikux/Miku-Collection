##
## This docker file from https://github.com/k3rnelpan1c-dev/uptime-kuma-helm
##

FROM docker.io/louislam/uptime-kuma:latest AS app-donor

FROM alpine:3.16.2 AS patch

WORKDIR /app
COPY --from=app-donor /app /app
COPY Patch/discordjs.patch discordjs.patch

RUN apk add patch && \
    patch server/notification-providers/discord.js < discordjs.patch && \
    rm discordjs.patch

FROM docker.io/node:16.17.1-bullseye-slim

ARG UID=3310
ARG GID=3310

# renovate: datasource=pypi depName=apprise versioning=pep440
ARG APPRISE_VERSION=1.0.0

# renovate: datasource=github-releases depName=cloudflare/cloudflared
ARG CLOUDFLARED_VERSION=2022.9.1

COPY --from=patch /app /app

RUN apt-get update -qqy \
    # Install Uptime-Kuma dependencies
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -qqy \
        python3 python3-pip python3-cryptography python3-six python3-yaml python3-click python3-markdown python3-requests python3-requests-oauthlib \
        sqlite3 iputils-ping util-linux dumb-init curl ca-certificates bash \
    && pip3 --no-cache-dir install apprise==${APPRISE_VERSION} \
    && rm -rf /var/lib/apt/lists/* \
    \
    # Download and install cloudflared
    && ARCH= && dpkgArch="$(dpkg --print-architecture)" \
    && case "${dpkgArch##*-}" in \
      amd64) ARCH='amd64';; \
      arm64) ARCH='arm64';; \
      armhf) ARCH='arm';; \
      *) echo "unsupported architecture"; exit 1 ;; \
    esac \
    && curl -fsSLo /usr/local/bin/cloudflared https://github.com/cloudflare/cloudflared/releases/download/${CLOUDFLARED_VERSION}/cloudflared-linux-${ARCH} \
    && chmod +x /usr/local/bin/cloudflared \
    \
    # Setup non-root system account + group
    && addgroup --system --gid ${GID} uptime-kuma || true \
    && adduser --system --disabled-login --ingroup uptime-kuma --no-create-home --home /nonexistent --gecos "uptime-kuma" --shell /bin/false --uid ${UID} uptime-kuma || true \
    && mkdir -p /app/data \
    && chown -R uptime-kuma:0 /app \
    && chmod -R g=u /app \
    \
    # Smoke Tests
    && set -ex || exit $?; \
      cloudflared version; \
      apprise --version;

HEALTHCHECK --interval=60s --timeout=30s --start-period=180s --retries=5 CMD node extra/healthcheck.js
ENV HOME=/app
WORKDIR /app
USER uptime-kuma
EXPOSE 3001
VOLUME ["/app/data"]
CMD ["/usr/bin/dumb-init", "--", "node", "server/server.js"]
