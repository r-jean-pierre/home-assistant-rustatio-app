# Rustatio Home Assistant App

## Installation

Add the repository to Home Assistant:

```text
https://github.com/r-jean-pierre/home-assistant-rustatio-app
```

Then install **Rustatio** from **Settings → Apps → Install app**.

The published App uses pre-built multi-architecture images from:

```text
ghcr.io/r-jean-pierre/home-assistant-rustatio-app
```

## Recommended companion integration

The App runs Rustatio and provides its web interface. For Home Assistant sensor
entities, install the companion HACS custom integration:

```text
https://github.com/r-jean-pierre/home-assistant-rustatio
```

The App publishes a Supervisor discovery record containing its internal
hostname and port. With the custom integration installed, Home Assistant can
offer Rustatio automatically under **Settings → Devices & services**.

Manual configuration remains available for Rustatio servers running elsewhere.

## Configuration

### `watch_folder`

Default:

```yaml
watch_folder: "/torrents"
```

The value is interpreted relative to Home Assistant `/share`.

Examples:

```yaml
watch_folder: "/torrents"
```

maps to:

```text
/share/torrents
```

and:

```yaml
watch_folder: "/downloads/torrent-files"
```

maps to:

```text
/share/downloads/torrent-files
```

Inside the App, the selected directory is always exposed to Rustatio as:

```text
/torrents
```

Both `torrents` and `/torrents` are accepted. Empty paths, `/`, `.` and `..`
path traversal segments are rejected.

## Read-only storage

Home Assistant `/share` is mounted at:

```text
/ha_share
```

with read-only permissions.

The selected source folder is linked to `/torrents`. Rustatio can read torrent
metadata but cannot modify the Home Assistant share through this mount.

Rustatio application state remains writable and persistent under `/data`.

## Ingress and sidebar

Ingress is the preferred access method.

The App starts an internal Nginx proxy on port `8099`. It adapts Rustatio's
root-relative assets, `fetch()` calls and `EventSource` calls to Home
Assistant's dynamic Ingress prefix.

Only the Home Assistant Ingress gateway is allowed to connect to the Nginx
Ingress listener.

## Optional direct LAN port

Container port `8080` is declared but has no host mapping by default.

If direct LAN access is required, assign a host port in the App's **Network**
configuration.

For example, mapping it to `8080` makes the direct UI available at:

```text
http://HOME_ASSISTANT_IP:8080
```

Direct access bypasses Home Assistant Ingress authentication. Use Rustatio's own
authentication if you expose this port on a network you do not fully trust.

Do not expose the direct Rustatio port to the public Internet.

## Automatic Home Assistant discovery

At startup the wrapper uses the Supervisor discovery API to publish:

```json
{
  "service": "rustatio",
  "config": {
    "host": "<internal app hostname>",
    "port": 8080
  }
}
```

Registration is idempotent: if this App already has a Rustatio discovery record,
the existing record is reused instead of creating duplicates.

The discovery endpoint is one of the Supervisor endpoints Apps may use without
requesting broad `hassio_api` access.

## Security model

Important properties:

```text
Ingress:       enabled
Protected:     enabled
AppArmor:      custom profile
Full access:   disabled
Docker API:    disabled
Host network:  disabled
Privileged:    none
/share:        read-only
Direct port:   disabled by default
```

## Logs

Startup logs identify:

- App version;
- pinned upstream Rustatio image;
- Rustatio internal port;
- Ingress proxy;
- selected watch folder;
- resolved read-only source path;
- Supervisor discovery status.

Genuine tracker errors and Rustatio authentication warnings remain visible.

Repeated watch-folder duplicate warnings and low-value HTTP tracing noise are
suppressed through the configured Rust log filter.

## Persistence and backups

Rustatio stores persistent state in:

```text
/data
```

The App uses cold backups, so Supervisor stops the App while its persistent data
is backed up.

The watch folder is an external read-only source and is not Rustatio state.

## Troubleshooting

### Selected watch folder does not exist

For:

```yaml
watch_folder: "/torrents"
```

verify that this exists:

```text
/share/torrents
```

Network Storage intended for this path should be configured in Home Assistant
with usage type **Share**.

### Ingress fails but Rustatio starts

Check the App logs for:

```text
Checking Nginx Ingress configuration
Starting Nginx Ingress proxy
Starting upstream Rustatio
```

If you temporarily enable direct port `8080` and direct access works, the issue
is isolated to the Ingress compatibility layer.

### Integration is not discovered

Verify that:

1. the Rustatio custom integration is installed and Home Assistant has been restarted;
2. the App log reports `Registered Home Assistant discovery` or
   `Home Assistant discovery already registered`;
3. Rustatio is running normally.

The integration can always be configured manually with the App's internal URL
if needed, but discovery is preferred because repository-installed Apps do not
use the `local-rustatio` hostname used by local development Apps.

## Upstream

Rustatio itself is maintained by `takitsu21`:

```text
https://github.com/takitsu21/rustatio
```

This App is an independent Home Assistant wrapper maintained by
`r-jean-pierre`.

App `1.0.0` pins Rustatio `2.9.1`.
