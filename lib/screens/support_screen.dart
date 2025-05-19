import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@aiguardian.com',
      query: 'subject=App Support',
    );
    await launchUrl(emailLaunchUri);
  }

  void _launchPhone() async {
    final Uri phoneLaunchUri = Uri(scheme: 'tel', path: '+1234567890');
    await launchUrl(phoneLaunchUri);
  }

  void _launchAddress() async {
    final Uri mapUri = Uri.parse('https://maps.app.goo.gl/4FNY5WMAbpX9Fiwb7');
    await launchUrl(mapUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Contact App Support',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.email),
                label: const Text('Email: support@aiguardian.com'),
                onPressed: _launchEmail,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.phone),
                label: const Text('Call: +1 234 567 890'),
                onPressed: _launchPhone,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.location_on),
                label: const Text('123 Main St, YourCity'),
                onPressed: _launchAddress,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
