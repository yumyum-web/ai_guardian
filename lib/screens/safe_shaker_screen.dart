import 'package:flutter/material.dart';
import 'package:shake_gesture/shake_gesture.dart';
import 'sos_screen.dart';

class SafeShakerScreen extends StatelessWidget {
  const SafeShakerScreen({super.key});

  void _navigateToSOS(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SOSScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Shaker'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ShakeGesture(
        onShake: () => _navigateToSOS(context),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.vibration, size: 100, color: Colors.pinkAccent),
                const SizedBox(height: 32),
                const Text(
                  'Shake your phone to trigger SOS mode!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'This feature allows you to quickly activate SOS by simply shaking your device.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
