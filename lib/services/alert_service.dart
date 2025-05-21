import 'package:ai_guardian/firebase_options.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class AlertService {
  static final AlertService _instance = AlertService._internal();
  factory AlertService() => _instance;
  AlertService._internal();

  Future<void> initialize() async {
    AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'sos_alerts',
        channelName: 'SOS Alerts',
        channelDescription: 'Notifications for SOS alerts',
        defaultColor: const Color(0xFFfb2aa7),
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
    ]);
    if (!await AwesomeNotifications().isNotificationAllowed()) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  Future<void> showSOSAlert(String message) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'sos_alerts',
        title: '🚨 SOS Alert',
        body: message,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  // Polls Firestore for SOS status and triggers notification if active
  Future<void> checkSOSStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    print(user);
    if (user == null) return;
    final uid = user.uid;
    final valoras =
        await FirebaseFirestore.instance
            .collection('users')
            .where('guardians', arrayContains: uid)
            .get();
    for (var valora in valoras.docs) {
      final doc =
          await FirebaseFirestore.instance
              .collection('sos')
              .doc(valora.id)
              .get();
      if (doc.exists && doc.data()?['active'] == true) {
        await showSOSAlert('${valora.data()['name']} is in SOS mode!');
      }
    }
  }
}

// Background fetch task
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(String taskId) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AlertService().initialize();
  await AlertService().checkSOSStatus();
  BackgroundFetch.finish(taskId);
}
