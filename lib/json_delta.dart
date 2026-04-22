// Copyright (c) Oddbit (https://oddbit.id)
//
// This source file is part of json_delta.
// Licensed under the Apache License, Version 2.0. See LICENSE and NOTICE.

/// Compute a JSON delta (patch) from an object's initial state to its
/// current state.
///
/// Mix [JsonDelta] into any class that implements [JsonSerializable] to get
/// a `toJsonDelta()` method returning only the fields that have changed
/// since the baseline was captured by `saveJsonDeltaState()`.
///
/// Pairs naturally with
/// [`json_serializable`](https://pub.dev/packages/json_serializable).
library;

import 'package:collection/collection.dart';

/// Contract for objects that can be serialized to a JSON map.
///
/// Classes using the [JsonDelta] mixin must implement this. The map returned
/// by [toJson] is the authoritative representation of the object's state for
/// the purpose of computing a delta.
abstract class JsonSerializable {
  /// Const constructor to allow subclasses to define their own const
  /// constructors. This class has no state of its own.
  const JsonSerializable();

  /// Returns a JSON-compatible map of the object's current state.
  ///
  /// The values should be JSON-encodable (primitives, [List], [Map], or types
  /// that your serializer handles — e.g. [DateTime] when paired with
  /// `json_serializable`'s converters).
  Map<String, dynamic> toJson();
}

/// Tracks an initial snapshot of an object's JSON state and produces a delta
/// (patch) of fields that have changed since the snapshot was taken.
///
/// Typical usage — compatible with
/// [json_serializable](https://pub.dev/packages/json_serializable):
///
/// ```dart
/// class Person extends JsonSerializable with JsonDelta {
///   String firstName;
///   String lastName;
///   int age;
///
///   Person({required this.firstName, required this.lastName, required this.age}) {
///     saveJsonDeltaState();
///   }
///
///   @override
///   Map<String, dynamic> toJson() => {
///         'firstName': firstName,
///         'lastName': lastName,
///         'age': age,
///       };
/// }
///
/// final person = Person(firstName: 'John', lastName: 'Doe', age: 30);
/// person.lastName = 'Smith';
/// person.age = 31;
/// person.toJsonDelta(); // {'lastName': 'Smith', 'age': 31}
/// ```
///
/// ### Limitations
///
/// * Removed top-level keys are not reported — the delta contains only
///   added or changed keys. This matches "PATCH-style" semantics where the
///   delta is applied on top of the existing server state.
/// * Nested [List] and [Map] values are compared deeply but returned in full
///   when any element inside changes. The delta is not recursive.
mixin JsonDelta on JsonSerializable {
  Map<String, dynamic>? _initialState;

  /// Captures the current JSON state as the baseline for future [toJsonDelta]
  /// calls.
  ///
  /// Call this in the constructor of the mixing class, or at any later point
  /// when the current state should be considered the new "clean" baseline
  /// (for example, after persisting to the server).
  void saveJsonDeltaState() {
    _initialState = _deepCopy(toJson());
  }

  /// Returns a map of fields that differ from the last baseline set by
  /// [saveJsonDeltaState].
  ///
  /// Values in the returned map are deep copies — mutating them does not
  /// affect the object's state or the stored baseline.
  ///
  /// Throws a [StateError] if [saveJsonDeltaState] has not been called — the
  /// baseline must be captured before a delta can be produced.
  Map<String, dynamic> toJsonDelta() {
    final baseline = _initialState;
    if (baseline == null) {
      throw StateError(
        'JsonDelta: saveJsonDeltaState() must be called before toJsonDelta(). '
        'Call saveJsonDeltaState() at the end of the constructor of '
        '$runtimeType (or after loading it from storage) to capture the '
        'initial state that future deltas are computed against.',
      );
    }

    final currentState = _deepCopy(toJson());
    final delta = <String, dynamic>{};

    currentState.forEach((key, val) {
      if (!baseline.containsKey(key) || !_deepEquals(val, baseline[key])) {
        delta[key] = val;
      }
    });

    return delta;
  }

  static const _collectionEquality = DeepCollectionEquality();

  bool _deepEquals(dynamic a, dynamic b) {
    if (identical(a, b)) return true;
    if (a is Map || a is List) {
      return _collectionEquality.equals(a, b);
    }
    return a == b;
  }

  Map<String, dynamic> _deepCopy(Map<String, dynamic> source) {
    return source.map((key, val) => MapEntry(key, _deepCopyValue(val)));
  }

  dynamic _deepCopyValue(dynamic value) {
    if (value is Map) {
      return value.map<String, dynamic>(
        (k, v) => MapEntry(k.toString(), _deepCopyValue(v)),
      );
    }
    if (value is List) {
      return value.map(_deepCopyValue).toList();
    }
    return value;
  }
}
