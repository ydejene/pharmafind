import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_find/core/constants/app_strings.dart';

void main() {
  group('AppStrings', () {
    test('returns English string for en locale', () {
      expect(AppStrings.get('app_name', 'en'), 'PharmaFind');
      expect(AppStrings.get('login', 'en'), 'Log In');
    });
  });
}
