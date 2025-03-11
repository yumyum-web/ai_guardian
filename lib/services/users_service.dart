import 'package:ai_guardian/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      throw 'Failed to add user: $e';
    }
  }

  Stream<UserModel?> user(String id) {
    return _firestore.collection('users').doc(id).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromMap(snapshot.data()!);
      } else {
        return null;
      }
    });
  }
}
