# Base image
FROM alpine:3.15

ENV HETRIX_AGENT_PARAMS=''

# About
LABEL org.opencontainers.image.version="0.2.0" \
      org.opencontainers.image.description="Container for Hetrix Linux agent" \
      org.opencontainers.image.authors="mmohoney" \
      org.opencontainers.image.source=https://github.com/xMikux/Miku-Collection

# Copy start.sh script
COPY ./start.sh ./start.sh

# Install All thing in one run
RUN set -xe; \
    apk add --no-cache wget iproute2 bash procps util-linux; \
    mkdir -p /etc/hetrixtools_dl; \
    wget https://raw.github.com/hetrixtools/agent/master/hetrixtools_install.sh -P /etc/hetrixtools_dl; \
    cp etc/hetrixtools_dl/hetrixtools_install.sh etc/hetrixtools_dl/hetrixtools_install_cp.sh; \
    addgroup -S hetrixtools && adduser -S appuser -G hetrixtools; \
    chmod 644 etc/hetrixtools_dl/hetrixtools_install_cp.sh; \
    chown root:root etc/hetrixtools_dl/hetrixtools_install_cp.sh; \
    chmod +x ./start.sh

ENTRYPOINT  ["/bin/bash", "./start.sh"]
