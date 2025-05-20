import 'dart:math';

import 'package:ai_guardian/screens/dashboard_screen.dart';
import 'package:ai_guardian/services/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LobbyScreen extends StatefulWidget {
  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final AuthService _authService = AuthService(FirebaseAuth.instance);
  User? user;
  final List<String> messages = [
    "Today, you take control of your destiny. You are unstoppable!",
    "You are a warrior. You are a survivor. You are a champion!",
    "You are a beacon of hope. You are a light in the darkness!",
  ];
  final carouselItems = [
    (
      'assets/images/lobby_carousel_1.png',
      'You are strong',
      'https://martialwaydojo.com/8-self-defense-moves-every-woman-needs-to-know/',
    ),
    (
      'assets/images/lobby_carousel_2.png',
      'You are brave',
      'https://www.dailymirror.lk/print/other/International-Womens-Day-2024-Inspiring-inclusion/117-278439',
    ),
    (
      'assets/images/lobby_carousel_3.png',
      'You are loved',
      'https://www.unwomen.org/en/what-we-do/ending-violence-against-women',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _authService.authStateChanges.listen((User? user) {
      setState(() {
        this.user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String name = user?.displayName ?? 'Valora';
    String photoUrl =
        user?.photoURL ??
        'https://via.assets.so/img.jpg?w=400&h=400&tc=red&bg=white&t=Error';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 0,
        children: [
          // Top Section
          Container(
            padding: EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
            decoration: BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        child: Text(
                          messages[Random().nextInt(messages.length)],
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(blurRadius: 3, color: Colors.black26),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 20,
                        ),
                        child: Text(
                          "Welcome, $name",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: CachedNetworkImageProvider(photoUrl),
                  ),
                ),
              ],
            ),
          ),

          // Strength Image Carousel
          Expanded(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              child: Stack(
                children: [
                  // Static icons grid background
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.12,
                      child: GridView.count(
                        crossAxisCount: 4,
                        mainAxisSpacing: 64,
                        crossAxisSpacing: 48,
                        padding: EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 30,
                        ),
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          Icon(Icons.shield, size: 40, color: Colors.pink),
                          Icon(
                            Icons.favorite,
                            size: 40,
                            color: Colors.redAccent,
                          ),
                          Icon(Icons.star, size: 40, color: Colors.amber),
                          Icon(
                            Icons.flash_on,
                            size: 40,
                            color: Colors.deepPurple,
                          ),
                          Icon(Icons.security, size: 40, color: Colors.blue),
                          Icon(
                            Icons.emoji_events,
                            size: 40,
                            color: Colors.green,
                          ),
                          Icon(Icons.lightbulb, size: 40, color: Colors.orange),
                          Icon(
                            Icons.directions_run,
                            size: 40,
                            color: Colors.teal,
                          ),
                          Icon(Icons.wb_sunny, size: 40, color: Colors.yellow),
                          Icon(Icons.bolt, size: 40, color: Colors.purple),
                          Icon(Icons.thumb_up, size: 40, color: Colors.cyan),
                          Icon(Icons.public, size: 40, color: Colors.indigo),
                        ],
                      ),
                    ),
                  ),
                  // CarouselSlider in foreground
                  Align(
                    alignment: Alignment.center,
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: 175,
                        autoPlay: true,
                        initialPage: Random().nextInt(3),
                      ),
                      items:
                          carouselItems.map((item) {
                            return Builder(
                              builder: (BuildContext context) {
                                return GestureDetector(
                                  onTap: () async {
                                    final url = Uri.parse(item.$3);
                                    try {
                                      if (!await launchUrl(
                                        url,
                                        mode: LaunchMode.externalApplication,
                                      )) {
                                        _showError('Could not open the link.');
                                      }
                                    } catch (e) {
                                      _showError('Error: $e');
                                    }
                                  },
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(40),
                                        child: Image.asset(
                                          item.$1,
                                          fit: BoxFit.cover,
                                          width: 300,
                                          height: 175,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        alignment: Alignment.bottomCenter,
                                        child: Text(
                                          item.$2,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                blurRadius: 10,
                                                color: Colors.black,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fly Safe Button
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: GestureDetector(
              onTap: _onTapFlySafe,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.2),
                      blurRadius: 5,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Image.asset('assets/images/logo.png', width: 100),
                    SizedBox(height: 5),
                    Text(
                      "Fly Safe",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onTapFlySafe() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DashboardScreen()),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  }
}
