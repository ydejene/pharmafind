import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pharmafind/core/constants/app_strings.dart';
import 'package:pharmafind/presentation/screens/profile/profile_screen.dart';

import '../helpers/test_providers.dart';

void main() {
  group('ProfileScreen', () {
    testWidgets('shows login required when unauthenticated', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        withTestProviders(
          settingsCubit: buildSettingsCubit(prefs),
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(AppStrings.get('login_required', 'en')),
        findsOneWidget,
      );
    });
  });
}
