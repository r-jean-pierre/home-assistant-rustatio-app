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

The App runs Rustatio and provides its web interface. To add **aggregate
Home Assistant sensors** for running/managed torrents, tracker errors,
watch-folder files and simulated transfer statistics, install the companion
**[Rustatio for Home Assistant integration](https://github.com/r-jean-pierre/home-assistant-rustatio)**.

Add that repository in HACS as a **custom Integration repository**:

```text
https://github.com/r-jean-pierre/home-assistant-rustatio
```

The App attempts to publish a Supervisor discovery record with its internal
hostname and port. When discovery succeeds, Home Assistant can propose Rustatio
under **Settings → Devices & services**. The integration can also be configured
manually when automatic discovery is unavailable.

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

Rustatio 2.14.1 uses a shared `/api/stream` SSE connection per browser tab.
For this upgrade, check live updates and logs through Ingress. Direct API/SSE
checks from a terminal do not validate the authenticated Ingress path.

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

Discovery depends on Supervisor access and the App's effective permissions.
A `403` during registration means discovery failed; it does **not** by itself
mean the Rustatio server or Ingress is unavailable. An isolated local test App
without the `discovery` declaration produced this warning; discovery in the
published App has not yet been revalidated for version 1.0.3.

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

## Selective restart of running torrents

During a normal Supervisor stop/restart, the wrapper queries
`/api/instances/summary` and saves only instance IDs in state `running` or
`starting` to `/data/rustatio-resume.json`. On the next start, once the Rustatio
API is ready, it attempts to restart those IDs with `/api/grid/start`.
Instances that were already stopped are **not** deliberately restarted.

The wrapper uses a 2-second connection timeout and a 5-second total timeout
on its readiness, save and restore API requests, so an unresponsive request
does not hang indefinitely. If save fails, the previous resume state is not
replaced; if restore fails, the resume file is kept for a later attempt.

Previous validation: selective restart was tested in Docker and the maintainer
also confirmed Ingress, torrent persistence and selective restart after the
production update to App 1.0.2 / Rustatio 2.13.0.

### App 1.0.3 / Rustatio 2.14.1 validation

On October 26, 2026, an isolated local copy was built from the candidate sources
and tested on the maintainer's Home Assistant installation:

- Supervisor installation, startup, clean stop and subsequent startup succeeded.
- Startup logs confirmed Rustatio 2.14.1, a valid Nginx configuration and the
  expected isolated watch-folder path.
- The direct summary API returned an empty instance list before and after restart.
- The direct SSE endpoint returned HTTP 200, `text/event-stream` and an initial
  empty `summaries` snapshot before and after restart.
- The maintainer confirmed version 2.14.1 through authenticated Ingress, working
  themes, page reload and a usable interface in two simultaneous browser tabs.
- Tests of the wrapper functions with a simulated API passed selective
  running/starting selection and resume-file preservation on errors.

These checks used an empty watch folder. They do not validate real torrent
persistence or selective resume on this candidate. Live instance/log events
through Ingress were not separately verified. The test copy omitted discovery
permission, so it does not validate production discovery. The read-only mount
declaration was checked; an actual write-denial test was not performed.
This local build does not establish validation of both supported architectures.
The production App was left unchanged.

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

App `1.0.3` pins Rustatio `2.14.1`.

