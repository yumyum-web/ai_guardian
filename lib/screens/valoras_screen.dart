import 'package:ai_guardian/screens/qr_scanner_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ValorasScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _sendRequest(String valoraId, String action) async {
    await _firestore.collection('requests').add({
      'guardianId': uid,
      'valoraId': valoraId,
      'action': action,
    });
  }

  Future<void> _scanQRCode(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QrScannerScreen()),
    );

    if (result != null) {
      await _sendRequest(result['uid'], 'add');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Valoras")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  _firestore
                      .collection('users')
                      .where('guardians', arrayContains: uid)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No Valoras'));
                }
                return ListView(
                  children:
                      snapshot.data!.docs.map((doc) {
                        return ListTile(
                          title: Text(doc['name']),
                          subtitle: Text(doc['email']),
                          trailing: IconButton(
                            icon: Icon(Icons.remove_circle),
                            onPressed: () => _sendRequest(doc.id, 'remove'),
                          ),
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
                      .where('guardianId', isEqualTo: uid)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No requests'));
                }
                return ListView(
                  children:
                      snapshot.data!.docs.map((doc) {
                        return ListTile(
                          title: Text(doc['valoraId']),
                          subtitle: Text(doc['action']),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => doc.reference.delete(),
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
        onPressed: () => _scanQRCode(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
