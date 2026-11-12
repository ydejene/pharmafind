import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pharmafind/core/constants/app_strings.dart';
import 'package:pharmafind/presentation/screens/splash/splash_screen.dart';

import '../helpers/test_providers.dart';

void main() {
  group('SplashScreen', () {
    testWidgets('renders logo and tagline', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        withTestProviders(
          settingsCubit: buildSettingsCubit(prefs),
          child: const MaterialApp(home: SplashScreen()),
        ),
      );

      expect(find.text('PharmaFind', findRichText: true), findsOneWidget);
      expect(find.text(AppStrings.get('tagline', 'en')), findsOneWidget);

      // Unmount so the splash screen's navigation timer ends without a route.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
