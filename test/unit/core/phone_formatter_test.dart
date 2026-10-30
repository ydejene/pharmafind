import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_find/core/utils/phone_formatter.dart';

void main() {
  group('PhoneFormatter', () {
    test('formats 9-digit local number', () {
      expect(PhoneFormatter.format('781234567'), '781 234 567');
    });

    test('formats short input', () {
      expect(PhoneFormatter.format('781'), '781');
      expect(PhoneFormatter.format('78123'), '781 23');
    });

    test('formatWithCountryCode adds +250', () {
      expect(
        PhoneFormatter.formatWithCountryCode('781234567'),
        '+250 781 234 567',
      );
    });

    test('formatWithCountryCode handles 0-prefix', () {
      expect(
        PhoneFormatter.formatWithCountryCode('0781234567'),
        '+250 781 234 567',
      );
    });

    test('formatWithCountryCode handles 250-prefix', () {
      expect(
        PhoneFormatter.formatWithCountryCode('250781234567'),
        '+250 781 234 567',
      );
    });

    test('validates correct Rwandan numbers', () {
      expect(PhoneFormatter.isValidRwandanNumber('781234567'), true);
      expect(PhoneFormatter.isValidRwandanNumber('0781234567'), true);
      expect(PhoneFormatter.isValidRwandanNumber('250781234567'), true);
    });

    test('rejects invalid numbers', () {
      expect(PhoneFormatter.isValidRwandanNumber('12345'), false);
      expect(PhoneFormatter.isValidRwandanNumber(''), false);
      expect(PhoneFormatter.isValidRwandanNumber('1234567890123'), false);
    });

    test('validate returns null for valid input', () {
      expect(PhoneFormatter.validate('0781234567'), isNull);
    });

    test('validate returns null for empty input', () {
      expect(PhoneFormatter.validate(''), isNull);
      expect(PhoneFormatter.validate(null), isNull);
    });

    test('validate returns error for invalid input', () {
      expect(PhoneFormatter.validate('12345'), isNotNull);
    });
  });
}
