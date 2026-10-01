ARG BUILD_ARCH
ARG BUILD_VERSION

FROM ghcr.io/takitsu21/rustatio:2.9.1

ARG BUILD_ARCH
ARG BUILD_VERSION

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl jq nginx \
    && rm -rf /var/lib/apt/lists/*

COPY ingress-nginx.conf /etc/nginx/nginx.conf
COPY ha-entrypoint.sh /ha-entrypoint.sh

RUN chmod +x /ha-entrypoint.sh \
    && printf '%s\n' "${BUILD_VERSION}" > /ha-app-version \
    && printf '%s\n' "ghcr.io/takitsu21/rustatio:2.9.1" > /ha-upstream-image

LABEL \
  io.hass.name="Rustatio" \
  io.hass.description="Rustatio for Home Assistant with Ingress" \
  io.hass.type="app" \
  io.hass.version="${BUILD_VERSION}" \
  io.hass.arch="${BUILD_ARCH}" \
  org.opencontainers.image.source="https://github.com/r-jean-pierre/home-assistant-rustatio-app"

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -fsS http://127.0.0.1:8080/ >/dev/null || exit 1

ENTRYPOINT ["/ha-entrypoint.sh"]
CMD ["/app/rustatio-server"]
