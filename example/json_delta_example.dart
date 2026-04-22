// Copyright (c) Oddbit (https://oddbit.id)
//
// This source file is part of json_delta.
// Licensed under the Apache License, Version 2.0. See LICENSE and NOTICE.

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

  // No changes yet.
  print(person.toJsonDelta()); // {}

  person.lastName = 'Smith';
  person.age = 31;

  // Only the changed fields come back.
  print(person.toJsonDelta()); // {lastName: Smith, age: 31}

  // Persist to your backend, then reset the baseline.
  person.saveJsonDeltaState();

  print(person.toJsonDelta()); // {}
}
