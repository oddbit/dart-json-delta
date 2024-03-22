library json_delta;

import "package:collection/collection.dart";

abstract class JsonSerializable {
  Map<String, dynamic> toJson();
}

abstract class JsonSerializable2 {
  Map<String, dynamic> toJson();
}

/// This mixin allows for any class that implements a `toJson` method to be
/// able to return the delta JSON from the time the object was created until
/// the current time. This allows for creating a sort of "patch JSON" or diff
/// that can be used to update a server with only the changes that have been
/// made.
///
/// E.g.
///   final person = Person("John", "Doe", 30);
///   person.lastName = "Smith";
///   person.age = 31;
///   final delta = person.toJsonDelta(); // {"lastName": "Smith", "age": 31}
mixin JsonDelta on JsonSerializable {
  Map<String, dynamic> _initialState = {};

  /// Saves the current state of the object to be used as the initial state
  /// for comparison later. This should be called in the constructor of the
  /// class that uses this mixin.
  ///
  /// It can be called at any time in later stages of the object's lifecycle
  /// if it makes sense to consider the state to be the initial state at that
  /// point.
  void saveState() {
    _initialState = _deepCopy(toJson());
  }

  /// Returns a JSON object that represents the changes that have been made
  Map<String, dynamic> toJsonDelta() {
    Map<String, dynamic> currentState = _deepCopy(toJson());
    Map<String, dynamic> delta = {};

    currentState.forEach((key, val) {
      if (!_initialState.containsKey(key) ||
          !_deepCompare(val, _initialState[key])) {
        delta[key] = val;
      }
    });

    return delta;
  }

  /// Compares two objects and returns true if they are equal, false otherwise.
  /// This method does a deep comparison of the two objects, meaning that it
  /// will compare the contents of lists and maps as well.
  bool _deepCompare(dynamic obj1, dynamic obj2) {
    if (obj1.runtimeType != obj2.runtimeType) {
      return false;
    }

    if (obj1 is Map || obj1 is List) {
      return const DeepCollectionEquality().equals(obj1, obj2);
    } else {
      return obj1 == obj2;
    }
  }

  /// Deep copies a map to avoid reference issues
  Map<String, dynamic> _deepCopy(Map<String, dynamic> obj) {
    return Map.from(obj).map((key, val) => MapEntry(key, _deepCopyHelper(val)));
  }

  /// Helper function for _deepCopy to handle nested structures
  dynamic _deepCopyHelper(dynamic obj) {
    switch (obj) {
      case Map():
        return _deepCopy(obj as Map<String, dynamic>);
      case List():
        return obj.map(_deepCopyHelper).toList();
      default:
        return obj;
    }
  }
}
