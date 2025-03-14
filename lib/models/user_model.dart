import 'package:ai_guardian/enums/role_enum.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final RoleEnum role;
  final List<String>? valoras;
  final List<String>? guardians;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.valoras,
    this.guardians,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      role: RoleEnum.values.firstWhere((role) => role.name == map['role']),
      name: map['name'],
      email: map['email'],
      valoras:
          map['valoras'] != null
              ? List<String>.from(map['valoras'])
              : <String>[],
      guardians:
          map['guardians'] != null
              ? List<String>.from(map['guardians'])
              : <String>[],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'valoras': valoras,
      'guardians': guardians,
    };
  }
}
