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

    test('returns French string for fr locale', () {
      expect(AppStrings.get('app_name', 'fr'), 'PharmaFind');
      expect(AppStrings.get('login', 'fr'), 'Se connecter');
    });
  });
}
