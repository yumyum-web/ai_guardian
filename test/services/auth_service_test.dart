import 'package:ai_guardian/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'auth_service_test.mocks.dart';

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

@GenerateMocks([FirebaseAuth])
void main() {
  group('AuthService tests', () {
    late MockFirebaseAuth firebaseAuth;
    late AuthService authService;

    setUp(() {
      firebaseAuth = MockFirebaseAuth();
      authService = AuthService(firebaseAuth);
    });

    test('signIn returns user on valid credentials', () async {
      final mockUserCredential = MockUserCredential();
      final mockUser = MockUser();

      when(
        firebaseAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => mockUserCredential);

      when(mockUserCredential.user).thenReturn(mockUser);

      final user = await authService.signIn('test@example.com', 'password123');

      expect(user, mockUser);
    });

    test('signIn throws error on invalid credentials', () async {
      when(
        firebaseAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'user-not-found'));

      expect(
        () => authService.signIn('test@example.com', 'wrong_password'),
        throwsA('Invalid email or password'),
      );
    });

    test('signUp returns user on successful registration', () async {
      final mockUserCredential = MockUserCredential();
      final mockUser = MockUser();

      when(
        firebaseAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => mockUserCredential);

      when(mockUserCredential.user).thenReturn(mockUser);

      final user = await authService.signUp(
        'newuser@example.com',
        'password123',
      );

      expect(user, mockUser);
    });

    test('signUp throws error on weak password', () async {
      when(
        firebaseAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'weak-password'));

      expect(
        () => authService.signUp('newuser@example.com', '123'),
        throwsA('The password provided is too weak.'),
      );
    });

    test('signOut calls FirebaseAuth signOut', () async {
      await authService.signOut();

      verify(firebaseAuth.signOut()).called(1);
    });

    test('getCurrentUser returns current user', () {
      final mockUser = MockUser();

      when(firebaseAuth.currentUser).thenReturn(mockUser);

      final user = authService.getCurrentUser();

      expect(user, mockUser);
    });

    test('authStateChanges returns FirebaseAuth authStateChanges stream', () {
      final mockStream = Stream<User?>.empty();

      when(firebaseAuth.authStateChanges()).thenAnswer((_) => mockStream);

      final stream = authService.authStateChanges;

      expect(stream, mockStream);
    });
  });
}
