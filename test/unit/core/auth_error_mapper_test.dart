import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_find/core/exceptions/auth_exception.dart';
import 'package:pharma_find/core/utils/auth_error_mapper.dart';

void main() {
  group('AuthErrorMapper', () {
    test('maps email-already-in-use to localized message', () {
      final error = AuthException.emailAlreadyInUse();
      final msg = AuthErrorMapper.toUserMessage(error, 'en');
      expect(msg, contains('already exists'));
    });

    test('maps weak-password to localized message', () {
      final error = AuthException.weakPassword();
      final msg = AuthErrorMapper.toUserMessage(error, 'en');
      expect(msg, contains('weak'));
    });

    test('maps user-not-found to localized message', () {
      final error = AuthException.userNotFound();
      final msg = AuthErrorMapper.toUserMessage(error, 'en');
      expect(msg, contains('No account'));
    });

    test('maps invalid-credentials to localized message', () {
      final error = AuthException.invalidCredentials();
      final msg = AuthErrorMapper.toUserMessage(error, 'en');
      expect(msg, contains('Invalid'));
    });

    test('maps network-error to localized message', () {
      final error = AuthException.networkError();
      final msg = AuthErrorMapper.toUserMessage(error, 'en');
      expect(msg, contains('Network'));
    });

    test('returns generic message for unknown errors', () {
      final msg = AuthErrorMapper.toUserMessage(Exception('oops'), 'en');
      expect(msg, contains('Something went wrong'));
    });

    test('maps to French when locale is fr', () {
      final error = AuthException.emailAlreadyInUse();
      final msg = AuthErrorMapper.toUserMessage(error, 'fr');
      expect(msg, contains('existe déjà'));
    });

    test('maps to Kinyarwanda when locale is rw', () {
      final error = AuthException.weakPassword();
      final msg = AuthErrorMapper.toUserMessage(error, 'rw');
      expect(msg, contains('riroroshye'));
    });
  });
}
