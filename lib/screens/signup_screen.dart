import 'package:ai_guardian/screens/login_screen.dart';
import 'package:ai_guardian/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
              AutofillGroup(
                child: Column(
                  children: [
                    _buildTextField(
                      "Enter your full name",
                      _nameController,
                      autofillHints: [AutofillHints.name],
                    ),
                    _buildTextField(
                      "Enter your email",
                      _emailController,
                      autofillHints: [
                        AutofillHints.username,
                        AutofillHints.email,
                      ],
                    ),
                    _buildTextField(
                      "Enter password",
                      _passwordController,
                      autofillHints: [AutofillHints.password],
                      obscureText: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Register Button
              ElevatedButton(
                onPressed: () async {
                  String name = _nameController.text.trim();
                  String email = _emailController.text.trim();
                  String password = _passwordController.text.trim();

                  if (name.isEmpty || email.isEmpty || password.isEmpty) {
                    _showErrorMessage("Please fill in all fields");
                    return;
                  }

                  try {
                    User? user = await _authService.signUp(email, password);

                    if (user != null) {
                      await user.updateDisplayName(name);
                      await user.updatePhotoURL(
                        "https://ui-avatars.com/api/?background=FFF&color=A94064&size=128&name=${name.replaceAll(' ', '+')}",
                      );
                    }
                  } catch (e) {
                    if (!context.mounted) return;

                    _showErrorMessage(e.toString());
                  }
                },
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
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginScreen()),
                      );
                    },
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
  Widget _buildTextField(
    String hintText,
    TextEditingController? controller, {
    List<String>? autofillHints,
    bool obscureText = false,
  }) {
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
        controller: controller,
        autofillHints: autofillHints,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
