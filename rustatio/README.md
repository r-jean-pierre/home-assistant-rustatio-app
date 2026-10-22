# Rustatio

Run [Rustatio](https://github.com/takitsu21/rustatio) as a Home Assistant App.

**App 1.0.2 · upstream Rustatio 2.13.0**. For Home Assistant dashboards and
aggregate sensors, pair it with the [Rustatio Home Assistant integration](https://github.com/r-jean-pierre/home-assistant-rustatio).

This App wraps the upstream Rustatio container without modifying Rustatio itself.
It adds the pieces needed for a clean Home Assistant experience:

- native Home Assistant Ingress;
- a sidebar panel;
- a configurable read-only torrent watch folder;
- persistent Rustatio state and selective restart of previously active torrents;
- Home Assistant Supervisor discovery;
- a custom AppArmor profile;
- pre-built `amd64` and `aarch64` images.

## Recommended companion integration

**[Rustatio for Home Assistant](https://github.com/r-jean-pierre/home-assistant-rustatio)**
adds aggregate Home Assistant sensors for Rustatio (running/managed torrents,
watch-folder files, tracker errors and simulated transfer statistics).

Add the repository to HACS as a custom **Integration** repository:

```text
https://github.com/r-jean-pierre/home-assistant-rustatio
```

The App attempts to advertise its internal hostname and port through Supervisor
discovery. If discovery is not available, manual integration configuration
remains possible.

## Watch folder

Rustatio always sees its watch folder as:

```text
/torrents
```

The Home Assistant source is configurable and is resolved below `/share`.

Default:

```yaml
watch_folder: "/torrents"
```

Path mapping:

```text
Home Assistant /share/torrents
          ↓ read-only
/ha_share/torrents
          ↓
/torrents
```

The entire Home Assistant share is mounted read-only. Rustatio cannot rename,
overwrite or delete files through this mount.

## Ingress

The Rustatio frontend expects root-relative assets and `/api/...` calls. Home
Assistant Ingress serves applications below a dynamic path.

A small Nginx compatibility proxy on port `8099` adapts the upstream frontend to
Ingress while Rustatio continues to run internally on port `8080`.

## Direct LAN access

Direct port `8080` is available as an optional network mapping but is
**disabled by default**.

Ingress is the recommended access method because Home Assistant handles
authentication before proxying the request.

If direct LAN access is enabled, Rustatio's own authentication settings apply;
the direct endpoint does not inherit Home Assistant authentication.

## Security

The App is designed to run protected and without broad host privileges.

It does not request Docker API access, host networking, full access, privileged
capabilities or hardware devices.

The custom AppArmor profile provides an additional confinement layer, and the
Home Assistant `/share` mount is read-only.

## Upstream version

App version `1.0.2` is built on the upstream Rustatio container:

```text
ghcr.io/takitsu21/rustatio:2.13.0
```

Pinning the upstream release makes App builds reproducible instead of silently
changing when the upstream `latest` tag moves.

See `DOCS.md` for installation, configuration and troubleshooting.
