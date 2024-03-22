import "package:flutter_test/flutter_test.dart";

import "package:json_delta/json_delta.dart";

class _TestUser extends JsonSerializable with JsonDelta {
  String firstName;
  String lastName;
  DateTime lastSeen;
  List<String> hobbies;
  Map<String, dynamic> config;

  _TestUser({
    required this.firstName,
    required this.lastName,
    required this.lastSeen,
    required this.hobbies,
    required this.config,
  }) {
    saveState();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'lastSeen': lastSeen,
      'hobbies': hobbies,
      'config': config,
    };
  }
}

main() {
  group('JSON Delta mixin', () {
    _TestUser? user;

    setUp(() {
      user = _TestUser(
        firstName: 'John',
        lastName: 'Doe',
        lastSeen: DateTime.now(),
        hobbies: ["Coding", "Testing"],
        config: {'theme': 'light', 'notifications': true, 'timeout': 30},
      );
    });

    test('User model exports full JSON', () {
      final expectedJson = {
        'firstName': 'John',
        'lastName': 'Doe',
        'lastSeen': user?.lastSeen,
        'hobbies': ["Coding", "Testing"],
        'config': {'theme': 'light', 'notifications': true, 'timeout': 30},
      };

      expect(user?.toJson(), expectedJson);
    });

    test("Changing simple string and date fields", () {
      final now = DateTime.now();
      user?.firstName = 'Jane';
      user?.lastSeen = now;

      final expectedDelta = {
        'firstName': 'Jane',
        'lastSeen': now,
      };

      expect(user?.toJsonDelta(), expectedDelta);
    });

    test("Changing an array returns whole array", () {
      user?.hobbies.add('Reading');
      final expectedDelta = {
        'hobbies': ['Coding', 'Testing', 'Reading'],
      };

      expect(user?.toJsonDelta(), expectedDelta);
    });

    test("Changing any field in Map returns the whole object", () {
      user?.config['theme'] = 'dark';

      final expectedDelta = {
        'config': {'theme': 'dark', 'notifications': true, 'timeout': 30},
      };

      expect(user?.toJsonDelta(), expectedDelta);
    });
  });
}
