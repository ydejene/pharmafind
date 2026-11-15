import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmafind/core/constants/app_strings.dart';
import 'package:pharmafind/data/datasources/mock_auth_datasource.dart';
import 'package:pharmafind/data/models/user_model.dart';
import 'package:pharmafind/presentation/screens/partner/partner_signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'partner_test_helper.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _en(String key) => AppStrings.get(key, 'en');

/// A data source that accepts the first registration and returns a partner user.
class _PartnerAuthDataSource extends MockAuthDataSource {
  @override
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    String role = 'patient',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return UserModel(
      uid: 'partner-uid',
      email: email,
      displayName: displayName,
      role: role,
      createdAt: DateTime(2026, 1, 1),
    );
  }
}

/// A data source that always rejects registration.
class _FailingAuthDataSource extends MockAuthDataSource {
  @override
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    String role = 'patient',
  }) async {
    throw Exception('Email already in use');
  }
}

Future<void> pumpSignupScreen(
  WidgetTester tester, {
  MockAuthDataSource? authDataSource,
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
      authDataSource: authDataSource,
      child: MaterialApp(
        home: const PartnerSignupScreen(),
        routes: {
          '/partner-license': (_) => const Scaffold(key: Key('license')),
          ...routes,
        },
      ),
    ),
  );
  await tester.pump();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PartnerSignupScreen', () {
    testWidgets('renders all required form fields', (tester) async {
      await pumpSignupScreen(tester);

      // Header texts
      expect(find.textContaining(_en('partner_program')), findsOneWidget);
      expect(find.textContaining(_en('register_pharmacy')), findsOneWidget);

      // Form fields: name, email, phone, password
      expect(find.byType(TextFormField), findsNWidgets(4));

      // Submit button
      expect(find.text(_en('continue_btn')), findsOneWidget);
    });

    testWidgets('shows validation errors when form is submitted empty', (
      tester,
    ) async {
      await pumpSignupScreen(tester);

      await tester.tap(find.text(_en('continue_btn')));
      await tester.pump();

      expect(find.text('Name is required'), findsOneWidget);
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Phone number is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('shows error snackbar on AuthError', (tester) async {
      await pumpSignupScreen(tester, authDataSource: _FailingAuthDataSource());

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Dr. User');
      await tester.enterText(fields.at(1), 'partner@example.com');
      await tester.enterText(fields.at(2), '+250700000000');
      await tester.enterText(fields.at(3), 'secret1');
      await tester.pump();

      await tester.tap(find.text(_en('continue_btn')));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(find.textContaining('Email already in use'), findsOneWidget);
    });

    testWidgets('navigates to /partner-license on successful registration', (
      tester,
    ) async {
      await pumpSignupScreen(tester, authDataSource: _PartnerAuthDataSource());

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Dr. Partner');
      await tester.enterText(fields.at(1), 'partner@example.com');
      await tester.enterText(fields.at(2), '+250700000000');
      await tester.enterText(fields.at(3), 'secret1');
      await tester.pump();

      await tester.tap(find.text(_en('continue_btn')));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('license')), findsOneWidget);
    });

    testWidgets('password visibility toggle works', (tester) async {
      await pumpSignupScreen(tester);

      // Password field is the 4th TextFormField (index 3).
      final passwordField = find.byType(TextFormField).at(3);
      await tester.enterText(passwordField, 'mypassword');
      await tester.pump();

      // The suffix icon button toggles obscure text.
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });
  });
}
