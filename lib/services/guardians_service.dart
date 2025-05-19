import 'package:cloud_firestore/cloud_firestore.dart';

class GuardiansService {
  final FirebaseFirestore _firestore;
  GuardiansService(this._firestore);

  Future<void> removeGuardian(String userId, String guardianId) async {
    await _firestore.collection('users').doc(userId).update({
      'guardians': FieldValue.arrayRemove([guardianId]),
    });
  }

  Future<void> acceptRequest(
    String userId,
    String action,
    String requestId,
    String guardianId,
  ) async {
    await _firestore.collection('users').doc(userId).update({
      'guardians':
          action == 'add'
              ? FieldValue.arrayUnion([guardianId])
              : FieldValue.arrayRemove([guardianId]),
    });
    await _firestore.collection('requests').doc(requestId).delete();
  }

  Future<void> rejectRequest(String requestId) async {
    await _firestore.collection('requests').doc(requestId).delete();
  }

  Stream<List<String>> guardiansStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((
      snapshot,
    ) {
      final data = snapshot.data();
      if (data == null || data['guardians'] == null) return <String>[];
      return List<String>.from(data['guardians']);
    });
  }

  Stream<QuerySnapshot> requestsStream(String userId) {
    return _firestore
        .collection('requests')
        .where('valoraId', isEqualTo: userId)
        .snapshots();
  }
}
