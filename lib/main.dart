import 'package:ai_guardian/firebase_options.dart';
import 'package:ai_guardian/screens/splash_screen.dart';
import 'package:ai_guardian/services/alert_service.dart';
import 'package:ai_guardian/services/geolocation_service.dart';
import 'package:ai_guardian/services/location_service.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

const textColor = Color(0xFF000000);
const backgroundColor = Color(0xFFffffff);
const primaryColor = Color(0xffff73c8);
const primaryFgColor = Color(0xFF000000);
const secondaryColor = Color(0xFFdedcff);
const secondaryFgColor = Color(0xFF000000);
const accentColor = Color(0xfffb2aa7);
const accentFgColor = Color(0xFF000000);

const colorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: primaryColor,
  onPrimary: primaryFgColor,
  secondary: secondaryColor,
  onSecondary: secondaryFgColor,
  tertiary: accentColor,
  onTertiary: accentFgColor,
  surface: backgroundColor,
  onSurface: textColor,
  error:
      Brightness.light == Brightness.light
          ? Color(0xffB3261E)
          : Color(0xffF2B8B5),
  onError:
      Brightness.light == Brightness.light
          ? Color(0xffFFFFFF)
          : Color(0xff601410),
);

/// Receive events from BackgroundGeolocation in Headless state.
@pragma('vm:entry-point')
Future<void> backgroundGeolocationHeadlessTask(
  bg.HeadlessEvent headlessEvent,
) async {
  print('📬 --> ${headlessEvent.name}');

  switch (headlessEvent.name) {
    case bg.Event.BOOT:
      bg.State state = await bg.BackgroundGeolocation.state;
      print("📬 didDeviceReboot: ${state.didDeviceReboot}");
    case bg.Event.TERMINATE:
      return;
    case bg.Event.LOCATION:
      backgroundUpdatePosition(headlessEvent.event as bg.Location);
  }
}

Future<void> backgroundUpdateCurrentPosition(String eventName) async {
  try {
    bg.Location location = await bg.BackgroundGeolocation.getCurrentPosition(
      samples: 1,
      persist: true,
      extras: {"event": eventName, "headless": true},
    );
    await backgroundUpdatePosition(location);
  } catch (error) {
    print("[backgroundUpdateCurrentPosition] Headless ERROR: $error");
  }
}

Future<void> backgroundUpdatePosition(bg.Location location) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  GeolocationService geolocationService = GeolocationService();
  LocationService locationService = LocationService(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
    geolocationService,
  );

  try {
    print("[backgroundUpdatePosition] Headless: $location");
    await locationService.shareLocation(
      location.timestamp,
      location.coords.longitude,
      location.coords.latitude,
    );
  } catch (error) {
    print("[backgroundUpdatePosition] Headless ERROR: $error");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AlertService().initialize();
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Register BackgroundGeolocation headless-task.
    bg.BackgroundGeolocation.registerHeadlessTask(
      backgroundGeolocationHeadlessTask,
    );

    // Configures the plugin
    bg.BackgroundGeolocation.ready(
      bg.Config(
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        distanceFilter: 10.0,
        stopOnTerminate: false,
        startOnBoot: true,
        debug: true,
        logLevel: bg.Config.LOG_LEVEL_VERBOSE,
        enableHeadless: true,
        notification: bg.Notification(
          title: 'AI Guardian',
          text: 'Location sharing is active',
          priority: bg.Config.NOTIFICATION_PRIORITY_HIGH,
          smallIcon: 'mipmap/ic_launcher',
          largeIcon: 'mipmap/ic_launcher',
        ),
      ),
    ).then((bg.State state) {
      print('[ready] - $state');
    });

    // Register background fetch for periodic SOS check
    BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless: true,
        startOnBoot: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.ANY,
      ),
      (String taskId) async {
        await AlertService().checkSOSStatus();
        BackgroundFetch.finish(taskId);
      },
      (String taskId) async {
        BackgroundFetch.finish(taskId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Guardian',
      theme: ThemeData(
        colorScheme: colorScheme,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      home: SplashScreen(),
    );
  }
}
