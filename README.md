# Rustatio Home Assistant App repository

Home Assistant App repository for [Rustatio](https://github.com/takitsu21/rustatio).

Repository maintained by **r-jean-pierre**.

## Add this repository

In Home Assistant, go to:

**Settings → Apps → Install app → Repositories**

and add:

```text
https://github.com/r-jean-pierre/home-assistant-rustatio-app
```

Then install **Rustatio**.

The App is distributed as a pre-built multi-architecture image for `amd64` and
`aarch64`, which is the preferred Home Assistant publication model.

## Companion Home Assistant integration

For aggregate Rustatio sensors, install:

```text
https://github.com/r-jean-pierre/home-assistant-rustatio
```

The App publishes Supervisor discovery information so the companion integration
can find the App without relying on a hard-coded `local-rustatio` hostname.

## Repository layout

```text
.
├── .github/workflows/
│   ├── build-app.yaml
│   ├── builder.yaml
│   └── lint.yaml
├── rustatio/
│   ├── translations/
│   ├── apparmor.txt
│   ├── CHANGELOG.md
│   ├── config.yaml
│   ├── Dockerfile
│   ├── DOCS.md
│   ├── ha-entrypoint.sh
│   ├── icon.png
│   ├── ingress-nginx.conf
│   ├── logo.png
│   └── README.md
├── LICENSE
├── NOTICE.md
└── repository.yaml
```

## Publishing

The GitHub Actions workflow builds `amd64` and `aarch64` images and publishes a
multi-architecture manifest to:

```text
ghcr.io/r-jean-pierre/home-assistant-rustatio-app:<app-version>
```

The version in `rustatio/config.yaml` is the image tag used by Home Assistant.

After the first successful GitHub Actions build, verify that the GHCR package is
publicly readable so Home Assistant installations can pull it anonymously.

## Upstream relationship

This repository does not modify Rustatio source code. The wrapper image is based
on the pinned upstream Rustatio container and adds only Home Assistant-specific
Ingress, storage, discovery and presentation layers.

See `rustatio/DOCS.md` for user documentation.
