import 'dart:async';

import 'package:ai_guardian/models/location_model.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final StreamController<bool> _sharingController =
      StreamController<bool>.broadcast();

  LocationService(this._firestore, this._auth) {
    bg.BackgroundGeolocation.state.then((bg.State? state) {
      _sharingController.add(state?.enabled ?? false);
      bg.BackgroundGeolocation.onEnabledChange((bool enabled) {
        _sharingController.add(enabled);
      });
      bg.BackgroundGeolocation.onLocation((bg.Location location) async {
        await shareLocation(
          location.timestamp,
          location.coords.longitude,
          location.coords.latitude,
        );
      });
    });
  }

  Future<void> startBackgroundLocation() async {
    await bg.BackgroundGeolocation.start();
  }

  Future<void> stopBackgroundLocation() async {
    await bg.BackgroundGeolocation.stop();
  }

  Future<void> shareLocation(
    String? timestamp,
    double longitude,
    double latitude,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw 'User not signed in';
    }
    await _firestore.collection('locations').doc(user.uid).set({
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
      'longitude': longitude,
      'latitude': latitude,
    });
  }

  Future<void> startSharing() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw 'User not signed in';
    }
    await startBackgroundLocation();
  }

  void stopSharing() {
    stopBackgroundLocation();
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
