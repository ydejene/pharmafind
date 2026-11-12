import 'package:flutter_test/flutter_test.dart';
import 'package:pharmafind/core/utils/input_formatters.dart';

void main() {
  group('RwandaPhoneValidator', () {
    test('accepts +250 format', () {
      expect(RwandaPhoneValidator.validate('+250781234567'), isNull);
    });

    test('accepts 07 format', () {
      expect(RwandaPhoneValidator.validate('0781234567'), isNull);
    });

    test('rejects too-short number', () {
      expect(RwandaPhoneValidator.validate('07812'), isNotNull);
    });

    test('rejects non-Rwandan number', () {
      expect(RwandaPhoneValidator.validate('+1234567890'), isNotNull);
    });

    test('returns null for empty input', () {
      expect(RwandaPhoneValidator.validate(''), isNull);
      expect(RwandaPhoneValidator.validate(null), isNull);
    });
  });
}
