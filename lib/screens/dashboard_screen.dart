import 'package:ai_guardian/screens/login_screen.dart';
import 'package:ai_guardian/services/auth_service.dart';
import 'package:ai_guardian/services/location_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  final LocationService _locationService = LocationService();
  bool _isSharingLocation = false;

  @override
  void initState() {
    super.initState();
    _locationService.isSharingLocation.listen((isSharing) {
      setState(() {
        _isSharingLocation = isSharing;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    User? user = _authService.getCurrentUser();
    return Scaffold(
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              child: Text(
                'PeerShip',
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
                _goToLogin();
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
      body: Column(
        children: [
          // Top section with profile and welcome message
          Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                spacing: 30,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: CachedNetworkImageProvider(
                      user?.photoURL ?? '',
                    ),
                  ),
                  Text(
                    "Welcome, ${user?.displayName ?? 'User'}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Dashboard Grid
          Expanded(
            child: GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
              ),
              children: [
                _buildDashboardTile(
                  image: 'assets/images/dashboard_sos.png',
                  label: "SOS",
                  bgColor: Colors.red,
                  textColor: Colors.white,
                  onTap: () {},
                ),
                _buildDashboardTile(
                  image: 'assets/images/dashboard_emergency_sms.png',
                  label: "Emergency SMS",
                  onTap: () {},
                ),
                _buildDashboardTile(
                  image: 'assets/images/dashboard_help_bot.png',
                  label: "Help Bot",
                  onTap: () {},
                ),
                _buildDashboardTile(
                  image: 'assets/images/dashboard_safe_shaker.png',
                  label: "Safe Shaker",
                  onTap: () {},
                ),
                _buildDashboardTile(
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
                          _locationService.startSharing(Duration(seconds: 5));
                        }
                        setState(() {
                          _isSharingLocation = !_isSharingLocation;
                        });
                      },
                      () {},
                    );
                  },
                ),
                _buildDashboardTile(
                  image: 'assets/images/dashboard_support.png',
                  label: "Support",
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
            TextButton(onPressed: () {
              onCancel();
              Navigator.of(context).pop();
            }, child: const Text('Cancel')),
            TextButton(onPressed: () {
              onConfirm();
              Navigator.of(context).pop();
            }, child: const Text('Confirm')),
          ],
        );
      },
    );
  }

  Widget _buildDashboardTile({
    required String image,
    required String label,
    Color? bgColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    bgColor ??= Theme.of(context).cardColor;
    textColor ??= Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 5,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, width: 100),
            SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }
}
