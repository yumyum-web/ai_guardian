import 'package:ai_guardian/services/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'safe_shaker_screen.dart';
import 'package:ai_guardian/services/safe_zones_service.dart';
import 'package:ai_guardian/services/geolocation_service.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

class SafeZonesScreen extends StatefulWidget {
  const SafeZonesScreen({super.key});

  @override
  State<SafeZonesScreen> createState() => _SafeZonesScreenState();
}

class _SafeZonesScreenState extends State<SafeZonesScreen> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  late GeolocationService _geolocationService;
  late SafeZonesService _safeZonesService;
  late Stream<Location> _location;
  Set<Polygon> _geofencePolygons = {};
  bool _monitorZones = false;

  @override
  void initState() {
    super.initState();
    _geolocationService = GeolocationService();
    _safeZonesService = SafeZonesService(_geolocationService);
    _location =
        LocationService(_firestore, _auth, _geolocationService).selfLocation();
    _fetchZones();
  }

  Future<void> _fetchZones() async {
    await _safeZonesService.fetchZones();
    Set<Polygon> polygons = {};
    int id = 1;
    for (var zone in _safeZonesService.highRiskZones) {
      polygons.add(
        Polygon(
          polygonId: PolygonId('high_risk_zone_$id'),
          points: [for (var p in zone) LatLng(p[0], p[1])],
          fillColor: Colors.red.withValues(alpha: 0.4),
          strokeColor: Colors.red.withValues(alpha: 0.8),
          strokeWidth: 2,
        ),
      );
      id++;
    }
    for (var zone in _safeZonesService.warningZones) {
      polygons.add(
        Polygon(
          polygonId: PolygonId('warning_zone_$id'),
          points: [for (var p in zone) LatLng(p[0], p[1])],
          fillColor: Colors.orange.withValues(alpha: 0.3),
          strokeColor: Colors.orange.withValues(alpha: 0.8),
          strokeWidth: 2,
        ),
      );
      id++;
    }
    setState(() {
      _geofencePolygons = polygons;
    });
  }

  void _onToggleMonitor(bool value) {
    setState(() {
      _monitorZones = value;
    });
    if (value) {
      _safeZonesService.addGeofenceCallback(_geofenceCallback);
    } else {
      _safeZonesService.removeGeofenceCallback(_geofenceCallback);
    }
  }

  void _geofenceCallback(bg.GeofenceEvent event) {
    if (event.action == 'ENTER' || event.action == 'DWELL') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SafeShakerScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Zones'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<Location>(
              stream: _location,
              builder: (context, snapshot) {
                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: const LatLng(7.8731, 80.7718),
                    zoom: 8,
                  ),
                  polygons: _geofencePolygons,
                  markers: <Marker>{
                    if (snapshot.data != null)
                      Marker(
                        markerId: const MarkerId('current_location'),
                        position: LatLng(
                          snapshot.data!.coords.latitude,
                          snapshot.data!.coords.longitude,
                        ),
                        infoWindow: const InfoWindow(title: 'You are here'),
                      ),
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SwitchListTile(
              title: const Text(
                'Monitor Zones',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              value: _monitorZones,
              onChanged: _onToggleMonitor,
              subtitle: const Text(
                'Navigate to Safe Shaker when entering a zone',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _safeZonesService.removeGeofenceCallback(_geofenceCallback);
    super.dispose();
  }
}
