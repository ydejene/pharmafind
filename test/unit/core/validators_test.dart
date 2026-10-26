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
  });
}
