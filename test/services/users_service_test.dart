import 'package:ai_guardian/enums/role_enum.dart';
import 'package:ai_guardian/models/user_model.dart';
import 'package:ai_guardian/services/users_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'users_service_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  Query,
  QuerySnapshot,
  QueryDocumentSnapshot,
])
void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentRef;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocSnapshot;
  late MockQuery<Map<String, dynamic>> mockQuery;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockQueryDoc;
  late UsersService service;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocumentRef = MockDocumentReference();
    mockDocSnapshot = MockDocumentSnapshot();
    mockQuery = MockQuery();
    mockQuerySnapshot = MockQuerySnapshot();
    mockQueryDoc = MockQueryDocumentSnapshot();

    // Inject the mock Firestore
    service = UsersService(mockFirestore);
  });

  test('addUser calls set() on the correct document', () async {
    final user = UserModel(
      id: 'u1',
      name: 'Alice',
      guardians: [],
      email: 'alice@email.com',
      role: RoleEnum.valora,
    );

    when(mockFirestore.collection('users')).thenReturn(mockCollection);
    when(mockCollection.doc('u1')).thenReturn(mockDocumentRef);
    when(mockDocumentRef.set(user.toMap())).thenAnswer((_) async {});

    await service.addUser(user);

    verify(mockCollection.doc('u1')).called(1);
    verify(mockDocumentRef.set(user.toMap())).called(1);
  });

  test('getUser returns a UserModel if document exists', () {
    fakeAsync((async) async {
      final dataMap = {'id': 'u1', 'name': 'Alice', 'guardians': <String>[]};

      when(mockFirestore.collection('users')).thenReturn(mockCollection);
      when(mockCollection.doc('u1')).thenReturn(mockDocumentRef);
      when(mockDocumentRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(true);
      when(mockDocSnapshot.data()).thenReturn(dataMap);

      final result = await service.getUser('u1');
      expect(result, isNotNull);
      expect(result, isA<UserModel>());
      expect(result!.id, equals('u1'));
    });
  });

  test('getUser returns null if document does not exist', () {
    fakeAsync((async) async {
      when(mockFirestore.collection('users')).thenReturn(mockCollection);
      when(mockCollection.doc('u1')).thenReturn(mockDocumentRef);
      when(mockDocumentRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(false);

      final result = await service.getUser('u1');
      expect(result, isNull);
    });
  });

  test('user() stream emits a UserModel when snapshot exists', () {
    fakeAsync((async) async {
      final dataMap = {'id': 'u1', 'name': 'Alice', 'guardians': <String>[]};

      when(mockFirestore.collection('users')).thenReturn(mockCollection);
      when(mockCollection.doc('u1')).thenReturn(mockDocumentRef);
      when(
        mockDocumentRef.snapshots(),
      ).thenAnswer((_) => Stream.value(mockDocSnapshot));
      when(mockDocSnapshot.exists).thenReturn(true);
      when(mockDocSnapshot.data()).thenReturn(dataMap);

      final events = <UserModel?>[];
      final sub = service.user('u1').listen(events.add);

      // Assert
      expect(events, [
        predicate<UserModel?>((user) => user != null && user.id == 'u1'),
      ]);
      await sub.cancel();
    });
  });

  test('getValoras() stream emits a list of UserModel for matching docs', () {
    fakeAsync((async) async {
      final docData = {
        'id': 'guardian1',
        'name': 'Bob',
        'guardians': ['u1'],
      };

      when(mockFirestore.collection('users')).thenReturn(mockCollection);
      when(
        mockCollection.where('guardians', arrayContains: 'u1'),
      ).thenReturn(mockQuery);
      when(
        mockQuery.snapshots(),
      ).thenAnswer((_) => Stream.value(mockQuerySnapshot));
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDoc]);
      when(mockQueryDoc.data()).thenReturn(docData);

      final events = <List<UserModel>>[];
      final sub = service.getValoras('u1').listen(events.add);

      // Assert
      expect(events, [
        predicate<List<UserModel>>(
          (list) => list.length == 1 && list.first.id == 'guardian1',
        ),
      ]);
      await sub.cancel();
    });
  });
}
