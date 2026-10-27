import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_find/core/constants/app_strings.dart';

void main() {
  group('AppStrings', () {
    test('returns English string for en locale', () {
      expect(AppStrings.get('app_name', 'en'), 'PharmaFind');
      expect(AppStrings.get('login', 'en'), 'Log In');
    });

    test('returns Kinyarwanda string for rw locale', () {
      expect(AppStrings.get('app_name', 'rw'), 'PharmaFind');
      expect(AppStrings.get('login', 'rw'), 'Injira');
    });

    test('falls back to English for unknown locale', () {
      expect(AppStrings.get('login', 'fr'), 'Log In');
    });

    test('returns key itself for unknown key', () {
      expect(AppStrings.get('nonexistent_key', 'en'), 'nonexistent_key');
    });

    test('all English keys have Kinyarwanda translations', () {
      final enKeys = [
        'app_name',
        'login',
        'register',
        'email',
        'password',
        'find_medicine',
        'search_medicine',
        'settings',
        'profile',
        'logout',
        'dark_mode',
        'notifications',
      ];
      for (final key in enKeys) {
        final rw = AppStrings.get(key, 'rw');
        expect(
          rw,
          isNot(equals(key)),
          reason: 'Missing Kinyarwanda translation for "$key"',
        );
      }
    });
  });
}
