import 'package:ai_guardian/widgets/dashboard_tile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

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
          child: Stack(
            children: [
              // Animated flowers background
              SizedBox(
                width: double.infinity,
                height: 180, // Adjust height as needed
                child: _AnimatedFlowersBackground(),
              ),
              Padding(
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
            ],
          ),
        ),
        // Dashboard Grid
        Expanded(
          child: GridView(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Changed from 2 to 3 columns
              childAspectRatio: 0.95, // Adjusted for better fit with 3 columns
            ),
            children: tiles,
          ),
        ),
      ],
    );
  }
}

class _AnimatedFlowersBackground extends StatefulWidget {
  const _AnimatedFlowersBackground();
  @override
  State<_AnimatedFlowersBackground> createState() =>
      _AnimatedFlowersBackgroundState();
}

class _AnimatedFlowersBackgroundState extends State<_AnimatedFlowersBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const int flowerCount = 8;
  // Hardcoded positions (x, y) as fractions of width and height (0..1)
  static const List<Offset> flowerPositions = [
    Offset(0.35, 0.65),
    Offset(0.40, 0.30),
    Offset(0.50, 0.00),
    Offset(0.55, 0.55),
    Offset(0.60, 0.35),
    Offset(0.75, 0.30),
    Offset(0.70, 0.60),
    Offset(0.80, 0.00),
  ];
  static const List<double> flowerSizes = [64, 56, 72, 60, 40, 52, 76, 48];
  static const List<double> flowerSpeeds = [
    0.7,
    0.9,
    0.6,
    1.0,
    0.3,
    0.65,
    0.95,
    0.75,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Use a continuous time value to avoid jitter on repeat
        final t =
            _controller.lastElapsedDuration != null
                ? _controller.lastElapsedDuration!.inMilliseconds / 1000.0
                : _controller.value * 8.0; // fallback to value * duration
        final List<Widget> flowers = [];
        for (int i = 0; i < flowerCount; i++) {
          final pos = flowerPositions[i];
          final size = flowerSizes[i];
          final speed = flowerSpeeds[i];
          flowers.add(_buildFlower(t, pos.dx, pos.dy, size, speed, i));
        }
        return Stack(children: flowers);
      },
    );
  }

  Widget _buildFlower(
    double t,
    double x,
    double y,
    double size,
    double speed,
    int i,
  ) {
    final dx = x + 0.02 * (speed * math.sin(i + t));
    final dy = y + 0.02 * (speed * math.cos(i + t * 2));
    final angle = t * 0.2 * math.pi * speed + i;
    return Positioned(
      left: MediaQuery.of(context).size.width * dx,
      top: 180 * dy, // Match the container height
      child: Transform.rotate(
        angle: angle,
        child: Icon(
          Icons.local_florist,
          color: Colors.pink.withValues(alpha: 0.18),
          size: size,
        ),
      ),
    );
  }
}
