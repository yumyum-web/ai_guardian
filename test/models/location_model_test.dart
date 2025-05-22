import 'package:flutter_test/flutter_test.dart';
import 'package:ai_guardian/models/location_model.dart';

void main() {
  group('LocationModel tests', () {
    test('creates instance from valid map', () {
      final map = {
        'timestamp': DateTime.now().toIso8601String(),
        'longitude': 12.34,
        'latitude': 56.78,
      };

      final location = LocationModel.fromMap(map);

      expect(location.timestamp, map['timestamp']);
      expect(location.longitude, map['longitude']);
      expect(location.latitude, map['latitude']);
    });

    test('throws error when map is missing required fields', () {
      final map = {'longitude': 12.34, 'latitude': 56.78};

      expect(() => LocationModel.fromMap(map), throwsA(isA<TypeError>()));
    });

    test('converts instance to valid map', () {
      final timestamp = DateTime.now().toIso8601String();
      final location = LocationModel(
        timestamp: timestamp,
        longitude: 12.34,
        latitude: 56.78,
      );

      final map = location.toMap();

      expect(map['timestamp'], timestamp);
      expect(map['longitude'], 12.34);
      expect(map['latitude'], 56.78);
    });
  });
}
