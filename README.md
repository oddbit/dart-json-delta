# json_delta

[![pub package](https://img.shields.io/pub/v/json_delta.svg)](https://pub.dev/packages/json_delta)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

A tiny Dart mixin that captures an initial JSON snapshot of an object and
produces a **delta** (patch) of the fields that have changed since. Use it to
send only the diff to your backend, log only what changed, or drive optimistic
UI updates.

Pure Dart — works in Flutter apps, server-side Dart, and CLI tools. Pairs
naturally with [`json_serializable`](https://pub.dev/packages/json_serializable).

## Install

```yaml
dependencies:
  json_delta: ^0.2.0
```

## Usage

Extend `JsonSerializable`, mix in `JsonDelta`, and call
`saveJsonDeltaState()` once the object is in its "clean" initial state —
typically at the end of the constructor.

```dart
import 'package:json_delta/json_delta.dart';

class Person extends JsonSerializable with JsonDelta {
  String firstName;
  String lastName;
  int age;

  Person({
    required this.firstName,
    required this.lastName,
    required this.age,
  }) {
    saveJsonDeltaState();
  }

  @override
  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'age': age,
      };
}

void main() {
  final person = Person(firstName: 'John', lastName: 'Doe', age: 30);
  person.lastName = 'Smith';
  person.age = 31;

  print(person.toJsonDelta()); // {lastName: Smith, age: 31}
}
```

After persisting the delta, call `saveJsonDeltaState()` again to reset the
baseline so subsequent edits produce a fresh delta.

### With `json_serializable`

`toJsonDelta()` only needs the map returned by your `toJson()`, so a
`@JsonSerializable()` class works with no extra wiring:

```dart
@JsonSerializable()
class Person extends JsonSerializable with JsonDelta {
  Person({required this.firstName, required this.age}) {
    saveJsonDeltaState();
  }

  String firstName;
  int age;

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PersonToJson(this);
}
```

## How it works

* `saveJsonDeltaState()` deep-copies the current `toJson()` output and stores
  it as the baseline.
* `toJsonDelta()` deep-copies the current `toJson()` output, walks the top-
  level keys, and returns the entries that are new or whose value differs
  deeply from the baseline. Deep comparison uses
  [`DeepCollectionEquality`](https://pub.dev/packages/collection) so nested
  maps and lists compare by structure, not reference.
* The stored baseline is never mutated by later `toJson()` calls, and the
  returned delta is a deep copy — mutating it does not touch your object.

## Limitations

* **Top-level only.** The delta is a flat map of changed top-level keys. If
  a nested map or list changes at any depth, the whole value appears in the
  delta — the diff is not recursive.
* **No removed-key reporting.** If a key is present in the baseline but
  missing from the current `toJson()`, it is not reported. This matches
  PATCH-style semantics where the delta is applied on top of the existing
  server state. To clear a field, leave the key in `toJson()` with a `null`
  value.

## Contributing

Issues and pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

Apache License 2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).

Copyright (c) [Oddbit](https://oddbit.id). If you publish a fork or
derivative work, retain the `LICENSE` and `NOTICE` files and clearly
identify your version as modified.
