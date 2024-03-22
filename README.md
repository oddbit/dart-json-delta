<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them.

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

## Description
Introducing a mixin class that implements a `toJsonDelta()` method that serializes the object to JSON but only retains a map  of values that has changed.

**E.g.**
```dart
final person = Person("John", "Doe", 30);
person.lastName = "Smith";
person.age = 31;
final delta = person.toJsonDelta(); // {"lastName": "Smith", "age": 31}
```

## Usage
See the tests. But important note is that the `saveState()` method must be called in the constructor.

```dart
class Person extends JsonSerializable with JsonDelta {
  String firstName;
  String lastName;
  int age;

  Person({
    required this.firstName,
    required this.lastName,
    required this.age,
  }) {
    saveState();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
    };
  }
}
```


## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
