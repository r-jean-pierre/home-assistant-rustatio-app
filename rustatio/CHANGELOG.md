# Changelog

## 1.0.3

- Update the pinned upstream Rustatio image from `2.13.0` to `2.14.1`.
- Include upstream theme additions, the shared per-tab SSE stream and updated
  torrent client versions.
- Include the upstream fallback to `announce-list` for blank announce URLs.
- Keep the existing Home Assistant wrapper and Ingress configuration.
- Validate an isolated local build on Home Assistant on October 26, 2026:
  installation, startup, clean stop and subsequent startup; direct summary API
  and initial SSE snapshot before and after restart.
- Confirm authenticated Ingress access, version 2.14.1, themes, page reload
  and a usable interface in two browser tabs.
- Pass mocked wrapper-function checks for selective resume and error handling.
- Validation limits: real torrent persistence/resume, live instance/log events
  through Ingress, production discovery, actual write denial on the share and
  both supported architectures were not validated by this isolated test.

## 1.0.2

- Update the pinned upstream Rustatio image from `2.9.1` to `2.13.0`.
- Bound Rustatio API requests used for startup readiness, shutdown state
  capture and selective restart (`--connect-timeout 2 --max-time 5`).
- Preserve the existing behavior of resuming only previously running/starting
  instances rather than starting intentionally stopped torrents.
- Validate local Home Assistant installation, startup and Ingress with
  Rustatio `2.13.0`; selective restart was also checked separately in Docker.
- Refresh documentation and highlight the companion
  [Rustatio Home Assistant integration](https://github.com/r-jean-pierre/home-assistant-rustatio).

## 1.0.0

- Initial public Home Assistant App release.
- Home Assistant Ingress and sidebar support.
- Configurable read-only torrent watch folder.
- Automatic discovery for the companion Rustatio Home Assistant integration.
- Optional direct LAN port, disabled by default.
- Multi-architecture pre-built images for amd64 and aarch64.
- Custom AppArmor confinement and persistent Rustatio state.
