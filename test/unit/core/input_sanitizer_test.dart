import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_find/core/utils/input_sanitizer.dart';

void main() {
  group('InputSanitizer', () {
    test('sanitizeName capitalizes each word', () {
      expect(InputSanitizer.sanitizeName('john doe'), 'John Doe');
      expect(InputSanitizer.sanitizeName('JANE SMITH'), 'Jane Smith');
    });

    test('sanitizeName trims and collapses whitespace', () {
      expect(InputSanitizer.sanitizeName('  john   doe  '), 'John Doe');
    });

    test('sanitizeEmail lowercases and trims', () {
      expect(InputSanitizer.sanitizeEmail('  Test@Email.COM  '),
          'test@email.com');
    });

    test('sanitizePhone strips non-digit characters except +', () {
      expect(InputSanitizer.sanitizePhone('+250 (78) 123-4567'),
          '+250781234567');
    });

    test('removeExcessiveWhitespace collapses spaces', () {
      expect(
        InputSanitizer.removeExcessiveWhitespace('  hello   world  '),
        'hello world',
      );
    });

    test('stripHtml removes tags', () {
      expect(
        InputSanitizer.stripHtml('<b>Hello</b> <i>World</i>'),
        'Hello World',
      );
    });

    test('stripHtml handles empty string', () {
      expect(InputSanitizer.stripHtml(''), '');
    });
  });
}
