import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 64),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Image.asset('assets/images/logo_extended.png', height: 150),
              SizedBox(height: 24),

              // Welcome Text
              Text(
                "Welcome Onboard!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Your safety is our mission.\nTogether, let’s create a safer world for every woman.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 24),

              // Input Fields
              _buildTextField("Enter your full name"),
              _buildTextField("Enter your email"),
              _buildTextField("Enter password", obscureText: true),
              _buildTextField("Confirm Password", obscureText: true),
              SizedBox(height: 20),

              // Register Button
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Register", style: TextStyle(fontSize: 16)),
              ),
              SizedBox(height: 16),

              // Sign In prompt
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 4,
                children: [
                  Text("Already have an account?"),
                  GestureDetector(
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                        color: Colors.pinkAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for text fields
  Widget _buildTextField(String hintText, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
