# The Astrel page: Caddy and the static files in site/.
# The base image is pinned by digest. Dependabot proposes each update.
FROM caddy:2.11.7-alpine@sha256:eb4d35b7452d1ab6171fbdbe8d9275b2301dad6dad92115d91e19fb9b24d510f AS caddy

# The Caddy binary has a file capability that lets it open ports below 1024.
# We use port 8080, and the container runs with no capabilities at all.
# With the file capability, the kernel then refuses to start Caddy. So we remove it.
# setcap only changes file metadata, so this stage runs on the build platform.
FROM --platform=$BUILDPLATFORM caddy:2.11.7-alpine@sha256:eb4d35b7452d1ab6171fbdbe8d9275b2301dad6dad92115d91e19fb9b24d510f AS nocap
COPY --from=caddy /usr/bin/caddy /caddy
RUN setcap -r /caddy 2>/dev/null || true; test -z "$(getcap /caddy)"

FROM caddy

LABEL org.opencontainers.image.source="https://github.com/iAmLakshya/astrel" \
      org.opencontainers.image.description="Astrel, the page at astrel.sh"

COPY --from=nocap /caddy /usr/bin/caddy
COPY Caddyfile /etc/caddy/Caddyfile
COPY site/ /srv/

# Run as the user "nobody". Caddy needs no root, because port 8080 is above 1024.
USER 65534:65534
EXPOSE 8080

# The base image starts Caddy with /etc/caddy/Caddyfile.
