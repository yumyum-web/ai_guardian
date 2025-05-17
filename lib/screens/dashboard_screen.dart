import 'package:ai_guardian/enums/role_enum.dart';
import 'package:ai_guardian/screens/guardians_screen.dart';
import 'package:ai_guardian/screens/locations_screen.dart';
import 'package:ai_guardian/screens/login_screen.dart';
import 'package:ai_guardian/screens/safe_shaker_screen.dart';
import 'package:ai_guardian/screens/valoras_screen.dart';
import 'package:ai_guardian/screens/sos_screen.dart';
import 'package:ai_guardian/services/auth_service.dart';
import 'package:ai_guardian/services/location_service.dart';
import 'package:ai_guardian/services/users_service.dart';
import 'package:ai_guardian/services/sos_service.dart';
import 'package:ai_guardian/widgets/dashboard.dart';
import 'package:ai_guardian/widgets/dashboard_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService(FirebaseAuth.instance);
  final UsersService _usersService = UsersService(FirebaseFirestore.instance);
  final LocationService _locationService = LocationService(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
  final SOSService _sosService = SOSService();
  User? user;
  bool _isSharingLocation = false;
  RoleEnum role = RoleEnum.valora;

  @override
  void initState() {
    super.initState();
    _authService.authStateChanges.listen((user) {
      if (user == null) {
        _goToLogin();
      }
      _usersService.user(user!.uid).listen((userModel) async {
        if (userModel == null) {
          _goToLogin();
        }
        setState(() {
          role = userModel!.role;
        });
        // Check SOS mode after user is loaded
        if (await _sosService.isSOSActive()) {
          _goToSOS();
        }
      });
      setState(() {
        this.user = user;
      });
    });
    _locationService.isSharingLocation.listen((isSharing) {
      setState(() {
        _isSharingLocation = isSharing;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              child: Text(
                'AI Guardian',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 36,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Sign Out'),
              onTap: () async {
                await _authService.signOut();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              color: Colors.white,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      body: Dashboard(
        user: user,
        tiles: switch (role) {
          RoleEnum.valora => _getValoraTiles(),
          RoleEnum.guardian => _getGuardianTiles(),
        },
      ),
    );
  }

  List<DashboardTile> _getValoraTiles() {
    return [
      DashboardTile(
        image: 'assets/images/dashboard_sos.png',
        label: "SOS",
        onTap: _goToSOS,
      ),
      DashboardTile(
        image: 'assets/images/dashboard_family.png',
        label: "Guardians",
        onTap: _goToGuardians,
      ),
      DashboardTile(
        image: 'assets/images/dashboard_emergency_sms.png',
        label: "Emergency SMS",
        onTap: () {},
      ),
      DashboardTile(
        image: 'assets/images/dashboard_help_bot.png',
        label: "Help Bot",
        onTap: () {},
      ),
      DashboardTile(
        image: 'assets/images/dashboard_safe_shaker.png',
        label: "Safe Shaker",
        onTap: _goToSafeShaker,
      ),
      DashboardTile(
        image: 'assets/images/dashboard_track_me.png',
        label: "Track Me (Advanced)",
        bgColor: _isSharingLocation ? Colors.green : null,
        textColor: _isSharingLocation ? Colors.white : null,
        onTap: () {
          _showConfirmation(
            "Location Sharing",
            "Are you sure you want to ${_isSharingLocation ? 'stop' : 'start'} sharing your location?",
            () {
              if (_isSharingLocation) {
                _locationService.stopSharing();
              } else {
                _locationService.startSharing();
              }
              setState(() {
                _isSharingLocation = !_isSharingLocation;
              });
            },
            () {},
          );
        },
      ),
      DashboardTile(
        image: 'assets/images/dashboard_support.png',
        label: "Support",
        onTap: () {},
      ),
    ];
  }

  List<DashboardTile> _getGuardianTiles() {
    return [
      DashboardTile(
        image: 'assets/images/dashboard_track_me.png',
        label: "Track Me (Advanced)",
        bgColor: _isSharingLocation ? Colors.green : null,
        textColor: _isSharingLocation ? Colors.white : null,
        onTap: _goToLocations,
      ),
      DashboardTile(
        image: 'assets/images/dashboard_family.png',
        label: "Valoras",
        onTap: _goToValoras,
      ),
      DashboardTile(
        image: 'assets/images/dashboard_emergency_sms.png',
        label: "Emergency SMS",
        onTap: () {},
      ),
    ];
  }

  Future<void> _showConfirmation(
    String title,
    String message,
    VoidCallback onConfirm,
    VoidCallback onCancel,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(child: Text(message)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                onCancel();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  void _goToLocations() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LocationsScreen()),
    );
  }

  void _goToGuardians() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GuardiansScreen()),
    );
  }

  void _goToValoras() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ValorasScreen()));
  }

  void _goToSOS() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SOSScreen()),
    );
  }

  void _goToSafeShaker() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SafeShakerScreen()),
    );
  }
}
