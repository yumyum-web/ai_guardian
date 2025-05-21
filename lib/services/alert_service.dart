import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class AlertService {
  static final AlertService _instance = AlertService._internal();
  factory AlertService() => _instance;
  AlertService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permissions for notifications
    await _messaging.requestPermission();
    // Optionally handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
            channelKey: 'sos_alerts',
            title: message.notification?.title ?? '🚨 SOS Alert',
            body: message.notification?.body ?? '',
            notificationLayout: NotificationLayout.Default,
          ),
        );
      }
    });
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
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

  Future<String?> getFcmToken() async {
    return await _messaging.getToken();
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}
