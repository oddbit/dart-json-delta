Introducing a mixin class that implements a `toJsonDelta()` method that serializes
the object to a JSON map of values of the changes in the object.

## Usage

```dart
final person = Person("John", "Doe", 30);
person.lastName = "Smith";
person.age = 31;
final delta = person.toJsonDelta(); // {"lastName": "Smith", "age": 31}
```


### Implement in your models

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
    saveJsonDeltaState();
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
This package is compatible with [`json_serializable`](https://pub.dev/packages/json_serializable)
which facilitates your generation of JSON.