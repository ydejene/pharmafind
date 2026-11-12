import 'package:flutter_test/flutter_test.dart';
import 'package:pharmafind/core/utils/email_utils.dart';

void main() {
  group('EmailUtils', () {
    group('normalize', () {
      test('trims whitespace and lowercases', () {
        expect(EmailUtils.normalize('  Test@Example.COM  '), 'test@example.com');
      });
    });

    group('extractDomain', () {
      test('returns domain from valid email', () {
        expect(EmailUtils.extractDomain('user@example.com'), 'example.com');
      });

      test('returns null for invalid email', () {
        expect(EmailUtils.extractDomain('notanemail'), isNull);
      });
    });

    group('maskEmail', () {
      test('masks middle characters of local part', () {
        expect(EmailUtils.maskEmail('john.doe@example.com'), 'j******e@example.com');
      });

      test('handles short local part', () {
        expect(EmailUtils.maskEmail('ab@example.com'), '**@example.com');
      });
    });
  });
}
