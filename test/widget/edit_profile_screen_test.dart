import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pharma_find/core/constants/app_strings.dart';
import 'package:pharma_find/presentation/screens/profile/edit_profile_screen.dart';

import '../helpers/test_providers.dart';

void main() {
  group('EditProfileScreen', () {
    testWidgets('renders name and phone fields', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        withTestProviders(
          settingsCubit: buildSettingsCubit(prefs),
          child: const MaterialApp(home: EditProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(AppStrings.get('full_name', 'en').toUpperCase()),
        findsOneWidget,
      );
      expect(
        find.text(AppStrings.get('your_phone', 'en').toUpperCase()),
        findsOneWidget,
      );
    });
  });
}
