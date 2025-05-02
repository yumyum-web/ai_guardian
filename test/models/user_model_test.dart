import 'package:flutter_test/flutter_test.dart';
import 'package:ai_guardian/models/user_model.dart';
import 'package:ai_guardian/enums/role_enum.dart';

void main() {
  group('UserModel tests', () {
    test('creates instance from valid map', () {
      final map = {
        'id': '098',
        'name': 'Jane Doe',
        'email': 'jane.doe@example.com',
        'role': 'valora',
        'valoras': [],
        'guardians': ['guardian1', 'guardian2'],
      };

      final user = UserModel.fromMap(map);

      expect(user.id, map['id']);
      expect(user.name, map['name']);
      expect(user.email, map['email']);
      expect(user.role, RoleEnum.valora);
      expect(user.valoras, map['valoras']);
      expect(user.guardians, map['guardians']);
    });

    test('handles missing optional fields in map', () {
      final map = {
        'id': '123',
        'name': 'John Doe',
        'email': 'john.doe@example.com',
        'role': 'guardian',
      };

      final user = UserModel.fromMap(map);

      expect(user.id, map['id']);
      expect(user.name, map['name']);
      expect(user.email, map['email']);
      expect(user.role, RoleEnum.guardian);
      expect(user.valoras, isEmpty);
      expect(user.guardians, isEmpty);
    });

    test('throws error when required fields are missing in map', () {
      final map = {
        'name': 'John Doe',
        'email': 'john.doe@example.com',
        'role': 'user',
      };

      expect(() => UserModel.fromMap(map), throwsA(isA<TypeError>()));
    });

    test('converts instance to valid map', () {
      final user = UserModel(
        id: '123',
        name: 'John Doe',
        email: 'john.doe@example.com',
        role: RoleEnum.guardian,
        valoras: ['valora1', 'valora2'],
        guardians: [],
      );

      final map = user.toMap();

      expect(map['id'], user.id);
      expect(map['name'], user.name);
      expect(map['email'], user.email);
      expect(map['role'], 'guardian');
      expect(map['valoras'], user.valoras);
      expect(map['guardians'], user.guardians);
    });

    test('handles null optional fields when converting to map', () {
      final user = UserModel(
        id: '123',
        name: 'John Doe',
        email: 'john.doe@example.com',
        role: RoleEnum.guardian,
      );

      final map = user.toMap();

      expect(map['id'], user.id);
      expect(map['name'], user.name);
      expect(map['email'], user.email);
      expect(map['role'], 'guardian');
      expect(map['valoras'], isNull);
      expect(map['guardians'], isNull);
    });
  });
}