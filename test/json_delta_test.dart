// Copyright (c) Oddbit (https://oddbit.id)
//
// This source file is part of json_delta.
// Licensed under the Apache License, Version 2.0. See LICENSE and NOTICE.

import 'package:json_delta/json_delta.dart';
import 'package:test/test.dart';

class _User extends JsonSerializable with JsonDelta {
  String firstName;
  String lastName;
  int age;
  double balance;
  bool active;
  String? nickname;
  DateTime lastSeen;
  List<String> hobbies;
  Map<String, dynamic> config;

  _User({
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.balance,
    required this.active,
    required this.lastSeen,
    required this.hobbies,
    required this.config,
    required this.nickname,
  }) {
    saveJsonDeltaState();
  }

  @override
  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'age': age,
        'balance': balance,
        'active': active,
        'nickname': nickname,
        'lastSeen': lastSeen,
        'hobbies': hobbies,
        'config': config,
      };
}

_User _buildUser() => _User(
      firstName: 'John',
      lastName: 'Doe',
      age: 30,
      balance: 12.5,
      active: true,
      nickname: null,
      lastSeen: DateTime.utc(2026, 1, 1),
      hobbies: const ['Coding', 'Testing'],
      config: const {'theme': 'light', 'notifications': true, 'timeout': 30},
    );

void main() {
  group('JsonDelta', () {
    late _User user;

    setUp(() {
      user = _buildUser();
    });

    test('toJson returns the full object', () {
      expect(user.toJson(), {
        'firstName': 'John',
        'lastName': 'Doe',
        'age': 30,
        'balance': 12.5,
        'active': true,
        'nickname': null,
        'lastSeen': DateTime.utc(2026, 1, 1),
        'hobbies': ['Coding', 'Testing'],
        'config': {'theme': 'light', 'notifications': true, 'timeout': 30},
      });
    });

    test('no changes produces an empty delta', () {
      expect(user.toJsonDelta(), isEmpty);
    });

    test('changing a string field is reflected in the delta', () {
      user.firstName = 'Jane';
      expect(user.toJsonDelta(), {'firstName': 'Jane'});
    });

    test('changing primitives of each type is reflected in the delta', () {
      user.age = 31;
      user.balance = 99.99;
      user.active = false;

      expect(user.toJsonDelta(), {
        'age': 31,
        'balance': 99.99,
        'active': false,
      });
    });

    test('changing a DateTime field is reflected in the delta', () {
      final newLastSeen = DateTime.utc(2026, 2, 2);
      user.lastSeen = newLastSeen;
      expect(user.toJsonDelta(), {'lastSeen': newLastSeen});
    });

    test('null → value and value → null are both detected', () {
      user.nickname = 'JD';
      expect(user.toJsonDelta(), {'nickname': 'JD'});

      user.saveJsonDeltaState();
      user.nickname = null;
      expect(user.toJsonDelta(), {'nickname': null});
    });

    test('mutating a list returns the whole list', () {
      user.hobbies = [...user.hobbies, 'Reading'];
      expect(user.toJsonDelta(), {
        'hobbies': ['Coding', 'Testing', 'Reading'],
      });
    });

    test('replacing a list with identical contents is not a change', () {
      user.hobbies = ['Coding', 'Testing'];
      expect(user.toJsonDelta(), isEmpty);
    });

    test('mutating a map returns the whole map', () {
      user.config = {...user.config, 'theme': 'dark'};
      expect(user.toJsonDelta(), {
        'config': {'theme': 'dark', 'notifications': true, 'timeout': 30},
      });
    });

    test('nested map changes are detected deeply', () {
      user.config = {
        ...user.config,
        'nested': {'a': 1, 'b': 2},
      };
      user.saveJsonDeltaState();

      user.config = {
        ...user.config,
        'nested': {'a': 1, 'b': 3},
      };

      expect(user.toJsonDelta(), {
        'config': {
          'theme': 'light',
          'notifications': true,
          'timeout': 30,
          'nested': {'a': 1, 'b': 3},
        },
      });
    });

    test('saveJsonDeltaState resets the baseline', () {
      user.firstName = 'Jane';
      user.saveJsonDeltaState();
      expect(user.toJsonDelta(), isEmpty);

      user.lastName = 'Roe';
      expect(user.toJsonDelta(), {'lastName': 'Roe'});
    });

    test('toJsonDelta does not mutate the baseline', () {
      user.firstName = 'Jane';
      user.toJsonDelta();
      user.firstName = 'John';
      expect(user.toJsonDelta(), isEmpty);
    });

    test('mutating a delta map does not affect the object state', () {
      final delta = user.toJsonDelta();
      delta['firstName'] = 'Mallory';
      expect(user.firstName, 'John');
    });

    test('mutating the source list after saving the state is still a change',
        () {
      final hobbies = <String>['A', 'B'];
      final tracked = _User(
        firstName: 'X',
        lastName: 'Y',
        age: 0,
        balance: 0,
        active: true,
        nickname: null,
        lastSeen: DateTime.utc(2026, 1, 1),
        hobbies: hobbies,
        config: const {},
      );

      hobbies.add('C');

      expect(tracked.toJsonDelta(), {
        'hobbies': ['A', 'B', 'C'],
      });
    });

    test('removed top-level keys are not reported (documented limitation)', () {
      final dyn = _DynamicBag({'a': 1, 'b': 2});
      dyn.remove('b');

      expect(dyn.toJsonDelta(), isEmpty);
    });

    test('added top-level keys are included in the delta', () {
      final dyn = _DynamicBag({'a': 1});
      dyn['b'] = 2;

      expect(dyn.toJsonDelta(), {'b': 2});
    });

    test(
        'toJsonDelta throws a clear StateError when '
        'saveJsonDeltaState was never called', () {
      final forgetful = _ForgetfulUser(firstName: 'John');

      expect(
        () => forgetful.toJsonDelta(),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            allOf(
              contains('saveJsonDeltaState()'),
              contains('toJsonDelta()'),
              contains('_ForgetfulUser'),
            ),
          ),
        ),
      );
    });
  });
}

class _ForgetfulUser extends JsonSerializable with JsonDelta {
  String firstName;

  _ForgetfulUser({required this.firstName});

  @override
  Map<String, dynamic> toJson() => {'firstName': firstName};
}

class _DynamicBag extends JsonSerializable with JsonDelta {
  final Map<String, dynamic> _data;

  _DynamicBag(Map<String, dynamic> initial) : _data = {...initial} {
    saveJsonDeltaState();
  }

  void operator []=(String key, dynamic value) => _data[key] = value;
  void remove(String key) => _data.remove(key);

  @override
  Map<String, dynamic> toJson() => {..._data};
}
