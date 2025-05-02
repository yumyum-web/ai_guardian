import 'package:ai_guardian/enums/role_enum.dart';
import 'package:ai_guardian/models/user_model.dart';
import 'package:ai_guardian/screens/dashboard_screen.dart';
import 'package:ai_guardian/screens/lobby_screen.dart';
import 'package:ai_guardian/screens/signup_screen.dart';
import 'package:ai_guardian/services/auth_service.dart';
import 'package:ai_guardian/services/users_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService(FirebaseAuth.instance);
  final UsersService _usersService = UsersService();
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
                "Welcome Back!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),

              // Welcome Image
              Image.asset('assets/images/login.png', height: 150),
              SizedBox(height: 24),

              // Input Fields
              AutofillGroup(
                child: Column(
                  children: [
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

              // Log In Button
              ElevatedButton(
                onPressed: () async {
                  String email = _emailController.text.trim();
                  String password = _passwordController.text.trim();

                  if (email.isEmpty || password.isEmpty) {
                    _showErrorMessage("Please fill in all fields.");
                    return;
                  }

                  try {
                    User? user = await _authService.signIn(email, password);
                    if (user == null) {
                      throw "Invalid credentials. Please try again.";
                    }

                    UserModel? userModel = await _usersService.getUser(
                      user.uid,
                    );
                    if (userModel == null) {
                      throw "Faulty user data. Please contact support.";
                    }

                    if (userModel.role == RoleEnum.valora) {
                      _goToLobby();
                    } else {
                      _goToDashboard();
                    }
                  } catch (e) {
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
                child: Text("Log In", style: TextStyle(fontSize: 16)),
              ),
              SizedBox(height: 16),

              // Sign Up prompt
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 4,
                children: [
                  Text("Don’t have an account?"),
                  GestureDetector(
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.pinkAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      _goToSignUp();
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
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
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

  void _goToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DashboardScreen()),
    );
  }
}
