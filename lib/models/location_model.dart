class LocationModel {
  final String timestamp;
  final double longitude;
  final double latitude;

  LocationModel({
    required this.timestamp,
    required this.longitude,
    required this.latitude,
  });

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      timestamp: map['timestamp'],
      longitude: map['longitude'],
      latitude: map['latitude'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'longitude': longitude,
      'latitude': latitude,
    };
  }
}
