import 'package:ai_guardian/models/user_model.dart';
import 'package:ai_guardian/services/users_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GuardiansScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final UsersService _usersService = UsersService(FirebaseFirestore.instance);

  Future<void> _removeGuardian(String guardianId) async {
    await _firestore.collection('users').doc(uid).update({
      'guardians': FieldValue.arrayRemove([guardianId]),
    });
  }

  Future<void> _acceptRequest(
    String action,
    String requestId,
    String guardianId,
  ) async {
    await _firestore.collection('users').doc(uid).update({
      'guardians': switch (action) {
        'add' => FieldValue.arrayUnion([guardianId]),
        'remove' => FieldValue.arrayRemove([guardianId]),
        _ => throw 'Invalid action: $action',
      },
    });
    await _firestore.collection('requests').doc(requestId).delete();
  }

  Future<void> _rejectRequest(String requestId) async {
    await _firestore.collection('requests').doc(requestId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Guardians")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<UserModel?>(
              stream: _usersService.user(uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null || snapshot.data!.guardians == null || snapshot.data!.guardians!.isEmpty) {
                  return Center(child: Text('No guardians'));
                }
                var userData = snapshot.data!;
                List<String> guardians = userData.guardians ?? [];

                return ListView(
                  children:
                      guardians.map((guardianId) {
                        return FutureBuilder<DocumentSnapshot>(
                          future:
                              _firestore
                                  .collection('users')
                                  .doc(guardianId)
                                  .get(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return SizedBox();
                            var guardianData = snapshot.data!;
                            return ListTile(
                              title: Text(guardianData['name']),
                              subtitle: Text(guardianData['email']),
                              trailing: IconButton(
                                icon: Icon(Icons.remove_circle),
                                onPressed: () => _removeGuardian(guardianId),
                              ),
                            );
                          },
                        );
                      }).toList(),
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  _firestore
                      .collection('requests')
                      .where('valoraId', isEqualTo: uid)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No requests'));
                }
                return ListView(
                  children:
                      snapshot.data!.docs.map((doc) {
                        return ListTile(
                          title: Text(doc['guardianId']),
                          subtitle: Text(doc['action']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.check_circle),
                                onPressed:
                                    () => _acceptRequest(
                                      doc['action'],
                                      doc.id,
                                      doc['guardianId'],
                                    ),
                              ),
                              IconButton(
                                icon: Icon(Icons.cancel),
                                onPressed: () => _rejectRequest(doc.id),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: Text("Scan to Add", textAlign: TextAlign.center),
                    content: SizedBox(
                      height: 250,
                      width: 200,
                      child: Center(
                        child: QrImageView(
                          data: '{"uid": "$uid", "name": "User"}',
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                      ),
                    ),
                  ),
            ),
        child: Icon(Icons.add),
      ),
    );
  }
}
