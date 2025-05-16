import 'package:ai_guardian/models/user_model.dart';
import 'package:ai_guardian/services/auth_service.dart';
import 'package:ai_guardian/services/location_service.dart';
import 'package:ai_guardian/services/users_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationsScreen extends StatefulWidget {
  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  final AuthService _authService = AuthService(FirebaseAuth.instance);
  final UsersService _usersService = UsersService(FirebaseFirestore.instance);
  final LocationService _locationService = LocationService(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
  List<UserModel> valoras = [];
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        _usersService.getValoras(user.uid).listen((valoras) async {
          setState(() {
            this.valoras = valoras;
          });
          await _listenToLocations();
        });
      }
    });
  }

  Future<void> _listenToLocations() async {
    BitmapDescriptor icon = await createCustomMarker();
    for (UserModel valora in valoras) {
      _locationService.location(valora.id).listen((locationModel) async {
        if (locationModel != null) {
          final location = LatLng(
            locationModel.latitude,
            locationModel.longitude,
          );
          final marker = Marker(
            markerId: MarkerId(valora.id),
            position: location,
            icon: icon,
            infoWindow: InfoWindow(
              title: valora.name,
              snippet:
                  'Last Updated: ${GetTimeAgo.parse(locationModel.timestamp.toDate())}',
            ),
          );
          setState(() {
            markers.removeWhere((m) => m.markerId.value == valora.id);
            markers.add(marker);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Location Viewer")),
      body:
          markers.isEmpty
              ? Center(child: Text("No locations to display"))
              : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: markers.first.position,
                  zoom: 15,
                ),
                markers: markers,
              ),
    );
  }

  Future<BitmapDescriptor> createCustomMarker() async {
    return await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(32, 48)),
      'assets/images/marker.png',
    );
  }
}
