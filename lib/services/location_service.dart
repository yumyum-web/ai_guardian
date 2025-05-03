import 'dart:async';
import 'package:ai_guardian/models/location_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocationService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GeolocatorPlatform _geolocator;
  Timer? _timer;
  final StreamController<bool> _sharingController =
      StreamController<bool>.broadcast();

  LocationService(this._firestore, this._auth, this._geolocator);

  Future<void> checkPermission() async {
    LocationPermission permission = await _geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw 'Location permission denied forever';
    }
  }

  Future<LocationPermission> getPermissionStatus() async {
    return await _geolocator.checkPermission();
  }

  Future<void> startSharing(Duration delay) async {
    await checkPermission();
    _timer?.cancel();
    User? user = _auth.currentUser;
    if (user == null) {
      throw 'User not signed in';
    }
    print(_firestore.collection("locations"));
    print(_firestore.collection('locations').doc("testUid"));
    _sharingController.add(true);
    _timer = Timer.periodic(delay, (timer) async {
      Position position = await _geolocator.getCurrentPosition();
      String uid = user.uid;
      print(_firestore);
      print(_firestore.collection('locations').doc("testUid"));

      await _firestore.collection('locations').doc(uid).set({
        'timestamp': FieldValue.serverTimestamp(),
        'longitude': position.longitude,
        'latitude': position.latitude,
      });
    });
  }

  void stopSharing() {
    _timer?.cancel();
    _sharingController.add(false);
  }

  Stream<bool> get isSharingLocation {
    return _sharingController.stream;
  }

  Stream<LocationModel?> location(String uid) {
    return _firestore.collection('locations').doc(uid).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists) {
        return null;
      }
      return LocationModel.fromMap(snapshot.data()!);
    });
  }
}
