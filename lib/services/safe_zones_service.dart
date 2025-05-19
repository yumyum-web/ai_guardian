import 'dart:convert';

import 'package:ai_guardian/services/geolocation_service.dart';
import 'package:http/http.dart' as http;

class SafeZonesService {
  final GeolocationService _geolocationService;
  final highRiskZones = <List<List<double>>>[];
  final warningZones = <List<List<double>>>[];

  SafeZonesService(this._geolocationService);

  Future<void> fetchZones() async {
    highRiskZones.clear();
    warningZones.clear();
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/zones'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      for (var zoneType in ['high_risk_zones', 'warning_zones']) {
        final zones = data[zoneType] as List?;
        if (zones == null) {
          continue;
        }
        for (var zone in zones) {
          final zoneList =
              (zone as List)
                  .map<List<double>>((p) => List<double>.from(p))
                  .toList();
          if (zoneType == 'high_risk_zones') {
            highRiskZones.add(zoneList);
          } else {
            warningZones.add(zoneList);
          }
        }
      }
    } else {
      throw Exception('Failed to load zones');
    }
  }

  Future<void> updateGeofences() async {
    List<Geofence> geofences = [];
    for (var zone in highRiskZones) {
      geofences.add(
        Geofence(
          identifier: 'high_risk_zone_${zone[0]}_${zone[1]}',
          vertices: zone,
        ),
      );
    }
    for (var zone in warningZones) {
      geofences.add(
        Geofence(
          identifier: 'warning_zone_${zone[0]}_${zone[1]}',
          vertices: zone,
        ),
      );
    }
    await _geolocationService.removeGeofences();
    await _geolocationService.addGeofences(geofences);
  }

  Future<void> addGeofenceCallback(Function(GeofenceEvent) callback) async {
    _geolocationService.addGeofenceCallback(callback);
  }

  Future<void> removeGeofenceCallback(Function(GeofenceEvent) callback) async {
    _geolocationService.removeGeofenceCallback(callback);
  }
}
