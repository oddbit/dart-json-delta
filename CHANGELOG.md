## 0.2.0

- **Breaking:** convert to a pure Dart package. The Flutter SDK is no longer
  a dependency — Flutter apps keep working since they include Dart, but
  non-Flutter consumers (server, CLI) can now depend on this package without
  pulling in Flutter.
- **Breaking:** replace `flutter_lints` with `lints` and `flutter_test` with
  `test` in the dev dependencies.
- **Breaking:** `toJsonDelta()` now throws a `StateError` with a clear
  message when `saveJsonDeltaState()` has not been called yet. Previously,
  the call silently returned the entire object as the delta — which hid the
  mistake instead of surfacing it.
- Bump `collection` to `^1.19.0`.
- Remove the deprecated `library json_delta;` directive.
- Add copyright headers to source files and a top-level `NOTICE` file.
- Expand test coverage: no-op deltas, primitive types, null transitions,
  nested-map changes, baseline reset, immutability of baseline and returned
  delta, added/removed top-level keys.
- Expand README with install instructions, how-it-works, and limitations.
- Add an `example/` directory.
- Publish workflow now uses Dart directly instead of Flutter.

## 0.1.1

- Updating class documentation

## 0.1.0

- Initial release.
