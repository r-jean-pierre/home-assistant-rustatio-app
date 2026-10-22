# Changelog

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
