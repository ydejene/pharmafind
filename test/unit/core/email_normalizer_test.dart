import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_find/core/utils/email_normalizer.dart';

void main() {
  group('EmailNormalizer', () {
    test('normalizes to lowercase and trims whitespace', () {
      expect(EmailNormalizer.normalize('  Test@Email.COM  '), 'test@email.com');
    });

    test('validates correct email format', () {
      expect(EmailNormalizer.isValidFormat('user@example.com'), true);
      expect(EmailNormalizer.isValidFormat('test@domain.rw'), true);
    });

    test('rejects invalid email format', () {
      expect(EmailNormalizer.isValidFormat('notanemail'), false);
      expect(EmailNormalizer.isValidFormat('@domain.com'), false);
      expect(EmailNormalizer.isValidFormat('user@'), false);
      expect(EmailNormalizer.isValidFormat(''), false);
    });

    test('extracts domain from email', () {
      expect(EmailNormalizer.getDomain('user@example.com'), 'example.com');
      expect(EmailNormalizer.getDomain('info@pharma.rw'), 'pharma.rw');
    });

    test('returns null for invalid email domain extraction', () {
      expect(EmailNormalizer.getDomain('notanemail'), null);
    });
  });
}
