FROM busybox:1.35.0-uclibc as busybox
FROM cloudflare/cloudflared:latest as cloudflared

# Main Image
FROM gcr.io/distroless/base-debian11:nonroot

# Copy Cloudflare binary to image
COPY --from=cloudflared --chown=nonroot /usr/local/bin/cloudflared /usr/local/bin/cloudflared

# Copy shell to image
COPY --from=busybox /bin/sh /bin/sh

# Copy entrypoint
COPY --chown=nonroot entrypoint.sh .

# Add nonroot user
USER nonroot

# Tunnel Token env
ENV TUNNEL_TOKEN=noToken

ENTRYPOINT [ "/bin/sh", "entrypoint.sh" ]
