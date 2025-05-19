import 'dart:async';

import 'package:ai_guardian/models/location_model.dart';
import 'package:ai_guardian/services/geolocation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GeolocationService _geolocationService;
  static bool _isSharing = false;
  static final StreamController<bool> _sharingController =
      StreamController<bool>.broadcast();

  LocationService(this._firestore, this._auth, this._geolocationService) {
    SharedPreferences.getInstance().then((prefs) {
      _isSharing = prefs.getBool('is_sharing') ?? false;
      _sharingController.add(_isSharing);
    });
  }

  void _setSharing(bool isSharing) {
    _isSharing = isSharing;
    _sharingController.add(isSharing);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('is_sharing', isSharing);
    });
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

  Future<void> _callback(Location location) async {
    await shareLocation(
      location.timestamp,
      location.coords.longitude,
      location.coords.latitude,
    );
  }

  void startSharing() {
    final user = _auth.currentUser;
    if (user == null) {
      throw 'User not signed in';
    }
    _geolocationService.addLocationCallback(_callback);
    _setSharing(true);
  }

  void stopSharing() {
    _geolocationService.removeLocationCallback(_callback);
    _setSharing(false);
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

  Stream<Location> selfLocation() {
    final controller = StreamController<Location>.broadcast();
    void callback(Location location) {
      controller.add(location);
    }

    controller.onListen = () {
      _geolocationService.addLocationCallback(callback);
    };
    controller.onCancel = () {
      _geolocationService.removeLocationCallback(callback);
      controller.close();
    };

    _geolocationService
        .currentLocation()
        .then((location) {
          controller.add(location);
        })
        .catchError((error) {
          print('Error getting initial self location: $error');
        });

    return controller.stream;
  }
}
