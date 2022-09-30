FROM cloudflare/cloudflared:latest as source

FROM gcr.io/distroless/base-debian11:nonroot

COPY --from=source --chown=nonroot /usr/local/bin/cloudflared /usr/local/bin/cloudflared

USER nonroot

ENV CF_TOKEN=noToken

ENTRYPOINT [ "cloudflared", "tunnel", "--no-autoupdate", "run", "--token", "${CF_TOKEN}" ]
