import 'package:ai_guardian/services/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    User? user = _authService.getCurrentUser();
    return Scaffold(
      body: Column(
        children: [
          // Top section with profile and welcome message
          Container(
            padding: EdgeInsets.all(20),
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
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
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
                    onTap: () {},
                  ),
                  _buildDashboardTile(
                    image: 'assets/images/dashboard_support.png',
                    label: "Support",
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
}
