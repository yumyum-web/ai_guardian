import 'dart:math';

import 'package:ai_guardian/screens/dashboard_screen.dart';
import 'package:ai_guardian/services/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    ('assets/images/lobby_carousel_1.png', 'You are strong'),
    ('assets/images/lobby_carousel_2.png', 'You are brave'),
    ('assets/images/lobby_carousel_3.png', 'You are loved'),
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
      backgroundColor: Colors.pink,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 30,
        children: [
          // Top Section
          Container(
            padding: EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Text(
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
                      Text(
                        "Welcome, $name",
                        style: TextStyle(fontSize: 18, color: Colors.white),
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
                          return Stack(
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
                                        blurRadius: 2,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }).toList(),
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
}
