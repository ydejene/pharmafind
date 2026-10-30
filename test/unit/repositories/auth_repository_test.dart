import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_find/core/exceptions/auth_exception.dart';
import 'package:pharma_find/data/repositories/auth_repository.dart';

void main() {
  late AuthRepository authRepo;

  setUp(() {
    authRepo = AuthRepository();
  });

  group('AuthRepository', () {
    test('starts unauthenticated', () {
      expect(authRepo.isAuthenticated, false);
      expect(authRepo.currentUser, isNull);
    });

    test('signInWithEmail returns user and sets current user', () async {
      final user = await authRepo.signInWithEmail('test@example.com', 'pass123');
      expect(user.email, 'test@example.com');
      expect(authRepo.isAuthenticated, true);
      expect(authRepo.currentUser, isNotNull);
    });

    test('signInWithEmail normalizes email', () async {
      final user = await authRepo.signInWithEmail('  Test@EXAMPLE.com  ', 'pass');
      expect(user.email, 'test@example.com');
    });

    test('registerWithEmail creates new user', () async {
      final user = await authRepo.registerWithEmail(
        email: 'new@example.com',
        password: 'secure123',
        displayName: 'New User',
      );
      expect(user.displayName, 'New User');
      expect(user.role, 'patient');
      expect(authRepo.isAuthenticated, true);
    });

    test('registerWithEmail throws on duplicate email', () async {
      await authRepo.registerWithEmail(
        email: 'dup@example.com',
        password: 'secure123',
        displayName: 'First User',
      );

      expect(
        () => authRepo.registerWithEmail(
          email: 'dup@example.com',
          password: 'another123',
          displayName: 'Second User',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('registerWithEmail throws on weak password', () async {
      expect(
        () => authRepo.registerWithEmail(
          email: 'weak@example.com',
          password: '12345',
          displayName: 'Weak User',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('signOut clears current user', () async {
      await authRepo.signInWithEmail('test@example.com', 'pass');
      expect(authRepo.isAuthenticated, true);

      await authRepo.signOut();
      expect(authRepo.isAuthenticated, false);
      expect(authRepo.currentUser, isNull);
    });

    test('signInWithGoogle returns demo user', () async {
      final user = await authRepo.signInWithGoogle();
      expect(user.email, 'demo@gmail.com');
      expect(user.displayName, 'Demo User');
    });

    test('updateUserProfile persists changes', () async {
      final user = await authRepo.signInWithEmail('test@example.com', 'pass');
      final updated = user.copyWith(displayName: 'Updated Name');
      await authRepo.updateUserProfile(updated);
      expect(authRepo.currentUser?.displayName, 'Updated Name');
    });
  });
}
