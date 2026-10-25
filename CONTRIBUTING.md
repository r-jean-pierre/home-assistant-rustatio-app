# Contributing to Rustatio Home Assistant App

Contributions to documentation, translations, bug fixes and Home Assistant
packaging are welcome.

## Choose the right project

- **This repository** contains the Home Assistant App wrapper: container
  packaging, startup and shutdown, Ingress, storage, Supervisor discovery,
  AppArmor, translations and build workflows.
- **[Upstream Rustatio](https://github.com/takitsu21/rustatio)** maintains
  Rustatio itself. Changes to its server, web interface or core behavior
  belong upstream. This wrapper does not modify upstream source code.
- **[Rustatio for Home Assistant](https://github.com/r-jean-pierre/home-assistant-rustatio)**
  maintains the companion integration and Home Assistant sensors.

Read the [README](README.md) and [App documentation](rustatio/DOCS.md) before
proposing a change. For a substantial feature, open an issue to discuss its
scope before starting implementation.

## Report a bug or request a feature

Search existing issues first. For bugs, use the repository's
[bug report form](https://github.com/r-jean-pierre/home-assistant-rustatio-app/issues/new?template=bug_report.yml)
and include:

- Home Assistant and App versions, plus the upstream Rustatio version;
- architecture (`amd64` or `aarch64`);
- steps to reproduce, expected behavior and observed behavior;
- relevant logs from the affected startup or operation;
- whether the problem affects Ingress, direct access, discovery or restart.

Remove tokens, passwords, tracker credentials, torrent passkeys and other
personal information from logs and screenshots.

For feature requests, explain the use case and the behavior you would like.
For vulnerabilities, follow [SECURITY.md](SECURITY.md) and use private
reporting rather than a public issue.

## Prepare a pull request

1. Fork this repository and create a branch from `main`.
2. Keep the change focused and follow the existing file style.
3. Update the relevant documentation and translations when behavior changes.
4. Describe the problem, the resulting behavior and how you checked it.
5. Open a pull request targeting `main`, linking any related issue.

State exactly which checks were run and which remain untested. Documentation
changes do not require a new App version. Coordinate release version changes
with the maintainer.

## Preserve the wrapper's behavior

- Keep the upstream image explicitly pinned in `rustatio/Dockerfile`. When
  changing it, keep `FROM` and the value written to `/ha-upstream-image`
  consistent. The App has its own version in `rustatio/config.yaml`.
- Keep `/share` mounted read-only at `/ha_share`. The `watch_folder` option
  is relative to `/share`, even with a leading slash; its schema remains
  `watch_folder: str`. Do not use `/ha_share/...` as the option value.
- Keep writable, persistent Rustatio state under `/data`.
- Preserve authenticated Home Assistant Ingress and keep direct LAN access
  disabled by default.
- Preserve selective restart: only previously `running` or `starting`
  instances are selected. Do not replace it with a Start All operation.
- Preserve the previous resume file if saving fails and retain it if the
  restore request fails. Keep API requests bounded by timeouts.

## Validate changes

From the repository root, run these basic checks:

```bash
bash -n rustatio/ha-entrypoint.sh
git diff --check
```

These checks cover shell syntax and whitespace; they do not validate runtime
behavior. Documentation-only changes can be checked by reviewing the Markdown
preview and links.

For changes to the image, wrapper, Ingress or storage, test an isolated local
Home Assistant App built from the proposed source:

- Give the test copy a distinct name and slug. Remove `image:` only from
  that copy so Supervisor builds it locally.
- Remove the `discovery` declaration from the test copy to keep it separate
  from production discovery. This test cannot validate production discovery;
  the wrapper may log a permission-related discovery warning.
- Use a dedicated empty folder, such as `/share/rustatio_ha_contribution_empty`,
  with `options.watch_folder: /rustatio_ha_contribution_empty`. Keep the
  read-only mapping and `schema.watch_folder: str`.
- Check installation, startup, shutdown and restart, and inspect logs from
  the latest startup rather than the entire log history.
- Open the test App through Home Assistant's **Open Web UI** button and check
  the interface and API requests. A successful local HTTP request or Nginx
  syntax check alone does not validate Ingress.

Never stop, uninstall, overwrite or delete the production App, its torrent
folder or its persistent data as part of a test. Do not copy production state
or torrents into the test App. Keep the test instance, files and logs after a
failure; cleanup must be an explicit action limited to the test resources.

If persistence or restart behavior changes, use non-production fixtures to
check that active instances resume and stopped instances remain stopped.
Report simulated API tests, Docker tests, real Home Assistant tests and
manual browser checks separately. A mock does not prove end-to-end behavior.

GitHub Actions runs the Home Assistant App linter. For monitored source
changes, the Builder workflow builds `amd64` and `aarch64` images on pull
requests without publishing them. Documentation-only changes may skip image
builds. CI builds do not replace functional Home Assistant testing.

## License

Contributions to this wrapper are made under the repository's
[MIT license](LICENSE). Preserve upstream attribution and third-party notices
when relevant.
