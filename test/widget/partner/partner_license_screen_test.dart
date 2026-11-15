import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmafind/core/constants/app_strings.dart';
import 'package:pharmafind/presentation/screens/partner/partner_license_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'partner_test_helper.dart';

String _en(String key) => AppStrings.get(key, 'en');

Future<void> pumpLicenseScreen(
  WidgetTester tester, {
  Map<String, WidgetBuilder> routes = const {},
}) async {
  tester.view.physicalSize = const Size(800, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    withPartnerTestProviders(
      settingsCubit: buildTestSettingsCubit(prefs),
      child: MaterialApp(
        home: const PartnerLicenseScreen(),
        routes: {
          '/partner-pending': (_) => const Scaffold(key: Key('pending')),
          ...routes,
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('PartnerLicenseScreen', () {
    testWidgets(
      'renders upload cards, simulation notice, and initially disabled submit button',
      (tester) async {
        await pumpLicenseScreen(tester);

        expect(find.text(_en('verification')), findsOneWidget);
        expect(find.text(_en('upload_docs')), findsOneWidget);
        expect(find.text(_en('pharmacy_license')), findsWidgets);
        expect(find.text(_en('rmoh_cert')), findsOneWidget);

        // Simulation notice
        expect(
          find.textContaining('Document upload simulation'),
          findsOneWidget,
        );

        final submitBtn = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, _en('submit_review')),
        );
        expect(submitBtn.onPressed, isNull);
      },
    );

    testWidgets(
      'submit button enables only when both documents are selected (simulation)',
      (tester) async {
        await pumpLicenseScreen(tester);

        // Tap first upload card (Pharmacy License)
        await tester.tap(find.text(_en('upload_license')));
        await tester.pumpAndSettle();

        expect(find.text('Selected (Simulation)'), findsOneWidget);

        // Still disabled
        var submitBtn = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, _en('submit_review')),
        );
        expect(submitBtn.onPressed, isNull);

        // Tap second upload card (RMOH Certificate)
        await tester.tap(find.text(_en('upload_rmoh')));
        await tester.pumpAndSettle();

        expect(find.text('Selected (Simulation)'), findsNWidgets(2));

        // Now enabled
        submitBtn = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, _en('submit_review')),
        );
        expect(submitBtn.onPressed, isNotNull);
      },
    );

    testWidgets('tapping enabled submit button navigates to /partner-pending', (
      tester,
    ) async {
      await pumpLicenseScreen(tester);

      await tester.tap(find.text(_en('upload_license')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(_en('upload_rmoh')));
      await tester.pumpAndSettle();

      await tester.tap(find.text(_en('submit_review')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('pending')), findsOneWidget);
    });
  });
}
