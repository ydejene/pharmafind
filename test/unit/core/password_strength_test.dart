import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_find/core/utils/password_strength.dart';

void main() {
  group('PasswordStrengthChecker', () {
    test('returns weak for short passwords', () {
      expect(
        PasswordStrengthChecker.check('abc'),
        PasswordStrength.weak,
      );
    });

    test('returns weak for simple 6-char password', () {
      expect(
        PasswordStrengthChecker.check('abcdef'),
        PasswordStrength.weak,
      );
    });

    test('returns fair for password with mixed case and digits', () {
      expect(
        PasswordStrengthChecker.check('Abcde123'),
        PasswordStrength.fair,
      );
    });

    test('returns strong for complex password', () {
      expect(
        PasswordStrengthChecker.check('MyP@ssw0rd!2024'),
        PasswordStrength.strong,
      );
    });

    test('label returns correct strings', () {
      expect(PasswordStrengthChecker.label(PasswordStrength.weak), 'Weak');
      expect(PasswordStrengthChecker.label(PasswordStrength.fair), 'Fair');
      expect(PasswordStrengthChecker.label(PasswordStrength.strong), 'Strong');
    });
  });
}
