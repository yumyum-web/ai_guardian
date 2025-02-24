import 'package:ai_guardian/screens/signup_screen.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage('assets/images/logo_extended.png'),
                height: 150,
              ),
              SizedBox(height: 20),

              Image.asset('assets/images/onboarding.png', width: 150),
              SizedBox(height: 30),

              // Title
              Text(
                "Your Safety, Our Priority",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),

              // Description
              Text(
                "Our women’s safety app empowers you with one-tap SOS alerts, live location tracking, and a volunteer network ready to help in any emergency. Stay connected, stay safe, and get the support you need, whenever you need it.",
                style: TextStyle(fontSize: 14, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),

              // Get Started Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SignUpScreen()),
                    );
                  },
                  child: Text(
                    "Get Started",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
