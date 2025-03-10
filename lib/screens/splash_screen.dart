import 'package:ai_guardian/screens/lobby_screen.dart';
import 'package:ai_guardian/screens/onboarding_screen.dart';
import 'package:ai_guardian/screens/signup_screen.dart';
import 'package:ai_guardian/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();
  final SharedPreferencesAsync prefs = SharedPreferencesAsync();

  @override
  void initState() {
    super.initState();
    checkFirstTimeUser();
  }

  Future<void> checkFirstTimeUser() async {
    bool firstTime = (await prefs.getBool('first_time')) ?? true;

    await Future.delayed(Duration(seconds: 2)); // Cosmetic splash delay

    if (firstTime) {
      prefs.setBool('first_time', false);
      _goToOnboarding();
    } else {
      _authService.authStateChanges.listen((user) {
        if (user == null) {
          _goToSignUp();
        } else {
          _goToLobby();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image(
              image: AssetImage('assets/images/logo_extended.png'),
              height: 150,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  void _goToOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => OnboardingScreen()),
    );
  }

  void _goToSignUp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => SignUpScreen()),
    );
  }

  void _goToLobby() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LobbyScreen()),
    );
  }
}
