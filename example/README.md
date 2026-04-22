# json_delta example

A minimal runnable example showing how to mix `JsonDelta` into a
serializable class and produce a delta of fields that have changed since
the baseline was captured.

## Run it

```sh
dart run example/json_delta_example.dart
```

## Code

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
    // Capture the "clean" baseline once the object is fully constructed.
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

  // No changes yet.
  print(person.toJsonDelta()); // {}

  person.lastName = 'Smith';
  person.age = 31;

  // Only the changed fields come back — perfect for a PATCH payload.
  print(person.toJsonDelta()); // {lastName: Smith, age: 31}

  // After persisting to your backend, reset the baseline.
  person.saveJsonDeltaState();

  print(person.toJsonDelta()); // {}
}
```
