# Contributing

Thanks for your interest in contributing to `json_delta`.

## How to contribute

1. **Fork the repository** on GitHub.
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/your-username/dart-json-delta.git
   cd dart-json-delta
   ```
3. **Create a branch** for your change:
   ```bash
   git checkout -b your-branch-name
   ```
4. **Install dependencies**:
   ```bash
   dart pub get
   ```
5. **Make your changes**, following the existing code style.
6. **Verify locally** before pushing:
   ```bash
   dart format --set-exit-if-changed .
   dart analyze
   dart test
   ```
7. **Commit and push**, then open a pull request with a clear description of
   the change and a reference to any related issue.

## Attribution

If you publish a fork or derivative work, retain the `LICENSE` and `NOTICE`
files and clearly identify your version as modified. See [NOTICE](NOTICE) for
details.

## Reporting issues

Please [open an issue](https://github.com/oddbit/dart-json-delta/issues) with
a minimal reproduction and a clear description of the expected vs. observed
behavior.

## Release process

Before tagging a release, update the `version:` field in `pubspec.yaml` and
add a new section to `CHANGELOG.md`. Then create and push a tag in the form
`pub-v<major>.<minor>.<patch>`:

```bash
git tag pub-v0.2.0
git push origin pub-v0.2.0
```

The `publish.yml` workflow will verify that the tag version matches
`pubspec.yaml`, run format, analyze, and test, publish to pub.dev via OIDC,
and create a GitHub Release with the matching `CHANGELOG.md` section as the
release notes. For the OIDC hand-off to work, the pub.dev package must have
an "Automated publishing" trust configured for this repository and the
`pub-v{{version}}` tag pattern.
