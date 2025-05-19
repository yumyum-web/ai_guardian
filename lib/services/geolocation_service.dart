import 'dart:async';

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

export 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    show Location, Geofence, GeofenceEvent;

class GeolocationService {
  static bool _isMonitoring = false;
  static List callbacks = [];

  GeolocationService() {
    bg.BackgroundGeolocation.state.then((bg.State? state) {
      _isMonitoring = state?.enabled ?? false;
    });
  }

  Future<bg.Location> currentLocation() {
    return bg.BackgroundGeolocation.getCurrentPosition();
  }

  Future<void> startMonitoring() async {
    if (_isMonitoring) {
      return;
    }
    await bg.BackgroundGeolocation.start();
    _isMonitoring = true;
  }

  Future<bool> stopMonitoring() async {
    if (!_isMonitoring) {
      return true;
    }
    if (callbacks.isNotEmpty) {
      return false;
    }
    await bg.BackgroundGeolocation.stop();
    _isMonitoring = false;
    return true;
  }

  void addLocationCallback(Function(bg.Location) callback) {
    bg.BackgroundGeolocation.onLocation(callback);
    callbacks.add(callback);
    startMonitoring();
  }

  void removeLocationCallback(Function(bg.Location) callback) {
    bg.BackgroundGeolocation.removeListener(callback);
    callbacks.remove(callback);
    stopMonitoring();
  }

  Future<void> addGeofences(List<bg.Geofence> geofences) async {
    await bg.BackgroundGeolocation.addGeofences(geofences);
  }

  Future<void> removeGeofences() async {
    await bg.BackgroundGeolocation.removeGeofences();
  }

  void addGeofenceCallback(Function(bg.GeofenceEvent) callback) {
    bg.BackgroundGeolocation.onGeofence(callback);
    callbacks.add(callback);
    startMonitoring();
  }

  void removeGeofenceCallback(Function(bg.GeofenceEvent) callback) {
    bg.BackgroundGeolocation.removeListener(callback);
    callbacks.remove(callback);
    stopMonitoring();
  }
}
