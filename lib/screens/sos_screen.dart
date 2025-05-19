import 'package:ai_guardian/services/geolocation_service.dart';
import 'package:flutter/material.dart';
import 'package:ai_guardian/services/sos_service.dart';
import 'package:ai_guardian/services/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_guardian/services/voice_recording_service.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> {
  late SOSService _sosService;
  late LocationService _locationService;
  late GeolocationService _geolocationService;

  @override
  void initState() {
    super.initState();
    _sosService = SOSService();
    _geolocationService = GeolocationService();
    _locationService = LocationService(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
      _geolocationService,
    );
    _startSOS();
  }

  Future<void> _startSOS() async {
    await _sosService.startSOS();
    _locationService.startSharing();
  }

  Future<void> _stopSOS() async {
    bool authenticated = await _sosService.authenticateUser();
    if (authenticated) {
      await _sosService.stopSOS();
      _locationService.stopSharing();
      await VoiceRecordingService().stopRecording();
      _popScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 24,
              children: [
                Icon(Icons.warning, color: Colors.red, size: 100),
                SizedBox(height: 24),
                Text(
                  'SOS Mode Active',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: _stopSOS,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: Size(200, 50),
                  ),
                  child: Text(
                    'I am safe',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                Text(
                  'Your location is being shared with your guardians. Press the button above to stop SOS mode.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  softWrap: true,
                ),
                StreamBuilder<bool>(
                  stream: VoiceRecordingService().isRecordingStream,
                  builder: (context, snapshot) {
                    final isRecording = snapshot.data ?? false;
                    return OutlinedButton.icon(
                      onPressed:
                          isRecording
                              ? null
                              : VoiceRecordingService().startRecording,
                      icon: Icon(Icons.mic),
                      label: Text(
                        isRecording ? 'Recording' : 'Start Recording',
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isRecording ? Colors.grey : Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _popScreen() async {
    Navigator.pop(context);
  }
}
