import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

class SOSService {
  static const String _sosKey = 'sos_mode';

  Future<void> startSOS() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sosKey, true);
  }

  Future<void> stopSOS() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sosKey, false);
  }

  Future<bool> isSOSActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sosKey) ?? false;
  }

  Future<bool> authenticateUser() async {
    final LocalAuthentication auth = LocalAuthentication();
    try {
      return await auth.authenticate(
        localizedReason: 'Please authenticate to turn off SOS mode',
        options: const AuthenticationOptions(),
      );
    } catch (e) {
      print('Authentication error: $e');
      return false;
    }
  }
}
