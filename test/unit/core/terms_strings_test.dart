import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_find/core/constants/app_strings.dart';

void main() {
  group('Terms and password strength strings', () {
    test('English terms strings exist', () {
      expect(AppStrings.get('accept_terms', 'en'), isNotEmpty);
      expect(AppStrings.get('terms_required', 'en'), isNotEmpty);
      expect(AppStrings.get('terms_link', 'en'), isNotEmpty);
      expect(AppStrings.get('privacy_link', 'en'), isNotEmpty);
    });

    test('password strength labels in all locales', () {
      for (final locale in ['en', 'rw', 'fr']) {
        expect(AppStrings.get('weak', locale), isNotEmpty);
        expect(AppStrings.get('fair', locale), isNotEmpty);
        expect(AppStrings.get('good', locale), isNotEmpty);
        expect(AppStrings.get('strong', locale), isNotEmpty);
      }
    });

    test('session expired message in all locales', () {
      for (final locale in ['en', 'rw', 'fr']) {
        expect(AppStrings.get('session_expired', locale), isNotEmpty);
      }
    });

    test('profile updated message in all locales', () {
      for (final locale in ['en', 'rw', 'fr']) {
        expect(AppStrings.get('profile_updated', locale), isNotEmpty);
      }
    });
  });
}
