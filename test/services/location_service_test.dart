import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_guardian/services/location_service.dart';
import 'package:ai_guardian/models/location_model.dart';
import 'location_service_test.mocks.dart';
import 'dart:async';
import 'package:fake_async/fake_async.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  FirebaseAuth,
  User,
  GeolocatorPlatform,
  DocumentSnapshot,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocationService tests', () {
    late LocationService locationService;
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference<Map<String, dynamic>> mockCollection;
    late MockDocumentReference<Map<String, dynamic>> mockDocument;
    late MockDocumentSnapshot<Map<String, dynamic>> mockSnapshot;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late MockGeolocatorPlatform mockGeolocator;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCollection = MockCollectionReference<Map<String, dynamic>>();
      mockDocument = MockDocumentReference();
      mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockGeolocator = MockGeolocatorPlatform();
      locationService = LocationService(
        mockFirestore,
        mockAuth,
        mockGeolocator,
      );
    });

    test('checkPermission requests permission if denied', () async {
      when(
        mockGeolocator.checkPermission(),
      ).thenAnswer((_) async => LocationPermission.denied);
      when(
        mockGeolocator.requestPermission(),
      ).thenAnswer((_) async => LocationPermission.whileInUse);

      await locationService.checkPermission();

      verify(mockGeolocator.requestPermission()).called(1);
    });

    test('checkPermission throws error if permission denied forever', () async {
      when(
        mockGeolocator.checkPermission(),
      ).thenAnswer((_) async => LocationPermission.deniedForever);

      expect(
        () => locationService.checkPermission(),
        throwsA('Location permission denied forever'),
      );
    });

    test('startSharing throws error if user not signed in', () async {
      when(
        mockGeolocator.checkPermission(),
      ).thenAnswer((_) async => LocationPermission.always);
      when(mockAuth.currentUser).thenReturn(null);

      expect(
        () => locationService.startSharing(Duration(seconds: 10)),
        throwsA('User not signed in'),
      );
    });

    test('startSharing updates Firestore with location periodically', () async {
      fakeAsync((async) async {
        when(
          mockGeolocator.checkPermission(),
        ).thenAnswer((_) async => LocationPermission.always);
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('testUid');
        when(mockGeolocator.getCurrentPosition()).thenAnswer(
          (_) async => Position(
            longitude: 12.34,
            latitude: 56.78,
            timestamp: DateTime.now(),
            accuracy: 1.0,
            altitude: 1.0,
            altitudeAccuracy: 1.0,
            heading: 1.0,
            headingAccuracy: 1.0,
            speed: 1.0,
            speedAccuracy: 1.0,
          ),
        );
        when(mockFirestore.collection('locations')).thenReturn(mockCollection);
        when(mockCollection.doc('testUid')).thenReturn(mockDocument);
        when(mockDocument.set(any)).thenAnswer((_) async {});

        await locationService.startSharing(Duration(seconds: 1));

        async.elapse(Duration(seconds: 1));

        verify(mockDocument.set(any)).called(1);
      });
    });

    test('stopSharing cancels the timer and updates sharing state', () {
      fakeAsync((async) async {
        final events = <bool>[];
        final sub = locationService.isSharingLocation.listen(events.add);
        locationService.stopSharing();

        // Assert
        expect(events, [false]);
        await sub.cancel();
      });
    });

    test('location stream returns null if document does not exist', () {
      fakeAsync((async) async {
        when(mockFirestore.collection('locations')).thenReturn(mockCollection);
        when(mockCollection.doc('testUid')).thenReturn(mockDocument);
        when(
          mockDocument.snapshots(),
        ).thenAnswer((_) => Stream.value(mockSnapshot));
        when(mockSnapshot.exists).thenReturn(false);

        final events = <LocationModel?>[];
        final sub = locationService.location('testUid').listen(events.add);

        // Assert
        expect(events, [null]);
        await sub.cancel();
      });
    });

    test('location stream returns LocationModel if document exists', () {
      fakeAsync((async) async {
        when(mockFirestore.collection('locations')).thenReturn(mockCollection);
        when(mockCollection.doc('testUid')).thenReturn(mockDocument);
        when(
          mockDocument.snapshots(),
        ).thenAnswer((_) => Stream.value(mockSnapshot));
        when(mockSnapshot.exists).thenReturn(true);
        when(mockSnapshot.data()).thenReturn({
          'timestamp': Timestamp.now(),
          'longitude': 12.34,
          'latitude': 56.78,
        });

        final events = <LocationModel?>[];
        final sub = locationService.location('testUid').listen(events.add);

        // Assert
        expect(events, [
          isA<LocationModel>()
              .having((l) => l.longitude, 'longitude', 12.34)
              .having((l) => l.latitude, 'latitude', 56.78),
        ]);
        await sub.cancel();
      });
    });
  });
}
