import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_notes/services/auth/auth_exceptions.dart';
import 'package:my_notes/services/auth/auth_service.dart';
import 'package:my_notes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();

    test('Should not be initialized to begin with', () {
      expect(provider.isInitialized, false);
    });

    test('Cannto log out if not initialized', () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test('Should be able to initialized', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('User should be null after initialization', () {
      expect(provider.currentUser, null);
    });

    test(
      'Should be able to initialize in less than 2 seconds',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(const Duration(seconds: 2)),
    );

    test('Create user should delegate to logIn function', () async {
      await expectLater(
        provider.createUser(
          email: 'h.wazhma25@gmail.com',
          password: 'password',
        ),
        throwsA(const TypeMatcher<InvalidCredentialsException>()),
      );

      final user = await provider.createUser(
        email: 'admin@gmail.com',
        password: 'password',
      );

      expect(user.isEmailVerified, false);
    });

    test('Logged in user should be able to get verified', () async {
      await provider.sendEmailVerification();

      final user = provider.currentUser;

      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to log out and log in again', () async {
      await provider.logOut();
      await provider.logIn(email: 'email', password: 'password');

      final user = provider.currentUser;

      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;

  bool get isInitialized => _isInitialized;

  @override
  String get providerId => throw UnimplementedError();

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!_isInitialized) {
      throw NotInitializedException();
    }
    await Future.delayed(const Duration(seconds: 1));

    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if (!_isInitialized) throw NotInitializedException();
    if (email == 'h.wazhma25@gmail.com' && password == 'password')
      throw InvalidCredentialsException();

    const user = AuthUser(email: 'test@gmail.com', isEmailVerified: false);
    _user = user;

    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!_isInitialized) throw NotInitializedException();
    if (_user == null) throw InvalidCredentialsException();

    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!_isInitialized) throw NotInitializedException();

    final user = _user;
    if (user == null) throw InvalidCredentialsException();

    const newUser = AuthUser(email: 'test@gmail.com', isEmailVerified: true);

    _user = newUser;
  }
}
