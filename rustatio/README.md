# Rustatio

Run [Rustatio](https://github.com/takitsu21/rustatio) as a Home Assistant App.

This App wraps the upstream Rustatio container without modifying Rustatio itself.
It adds the pieces needed for a clean Home Assistant experience:

- native Home Assistant Ingress;
- a sidebar panel;
- a configurable read-only torrent watch folder;
- persistent Rustatio state;
- Home Assistant Supervisor discovery;
- a custom AppArmor profile;
- pre-built `amd64` and `aarch64` images.

## Home Assistant integration

For Home Assistant sensors, install the companion custom integration:

`https://github.com/r-jean-pierre/home-assistant-rustatio`

When both the App and the custom integration are installed, the App advertises
its internal hostname and port through Supervisor discovery. Home Assistant can
then offer Rustatio as a discovered integration without requiring users to know
the repository-specific internal DNS name.

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

App version `1.0.0` is built on the upstream Rustatio container:

```text
ghcr.io/takitsu21/rustatio:2.9.1
```

Pinning the upstream release makes App builds reproducible instead of silently
changing when the upstream `latest` tag moves.

See `DOCS.md` for installation, configuration and troubleshooting.
