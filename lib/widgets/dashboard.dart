import 'package:ai_guardian/widgets/dashboard_tile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  final User? user;
  final List<DashboardTile> tiles;

  Dashboard({required this.user, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top section with profile and welcome message
        Container(
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              spacing: 30,
              children: [
                CircleAvatar(
                  radius: 50,
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
            children: tiles,
          ),
        ),
      ],
    );
  }
}
