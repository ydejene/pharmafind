import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_find/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('returns error for empty email', () {
        expect(Validators.validateEmail(''), isNotNull);
        expect(Validators.validateEmail(null), isNotNull);
      });

      test('returns error for invalid email', () {
        expect(Validators.validateEmail('notanemail'), isNotNull);
        expect(Validators.validateEmail('missing@'), isNotNull);
      });

      test('returns null for valid email', () {
        expect(Validators.validateEmail('test@example.com'), isNull);
        expect(Validators.validateEmail('user.name@domain.rw'), isNull);
      });
    });

    group('validatePassword', () {
      test('returns error for short password', () {
        expect(Validators.validatePassword('123'), isNotNull);
        expect(Validators.validatePassword(''), isNotNull);
      });

      test('returns null for valid password', () {
        expect(Validators.validatePassword('password123'), isNull);
        expect(Validators.validatePassword('sixcha'), isNull);
      });
    });

    group('validateConfirmPassword', () {
      test('returns error when passwords dont match', () {
        expect(
          Validators.validateConfirmPassword('abc123', 'def456'),
          isNotNull,
        );
      });

      test('returns null when passwords match', () {
        expect(Validators.validateConfirmPassword('abc123', 'abc123'), isNull);
      });
    });

    group('validateName', () {
      test('returns error for empty name', () {
        expect(Validators.validateName(''), isNotNull);
        expect(Validators.validateName(null), isNotNull);
      });

      test('returns null for valid name', () {
        expect(Validators.validateName('John Doe'), isNull);
      });
    });
  });
}
