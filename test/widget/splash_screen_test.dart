import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmafind/core/constants/app_strings.dart';
import 'package:pharmafind/core/constants/auth_routes.dart';
import 'package:pharmafind/data/datasources/mock_auth_datasource.dart';
import 'package:pharmafind/data/datasources/mock_pharmacy_datasource.dart';
import 'package:pharmafind/data/models/pharmacy_model.dart';
import 'package:pharmafind/data/models/user_model.dart';
import 'package:pharmafind/presentation/screens/splash/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'partner/partner_test_helper.dart';

class _DelayedAuthDataSource extends MockAuthDataSource {
  final Completer<UserModel?> completer = Completer<UserModel?>();

  @override
  Future<UserModel?> getCurrentUser() => completer.future;
}

class _FixedAuthDataSource extends MockAuthDataSource {
  final UserModel? user;
  _FixedAuthDataSource(this.user);

  @override
  Future<UserModel?> getCurrentUser() async => user;
}

void main() {
  group('SplashScreen Startup Flow', () {
    testWidgets('renders logo and tagline', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        withPartnerTestProviders(
          settingsCubit: buildTestSettingsCubit(prefs),
          child: const MaterialApp(home: SplashScreen()),
        ),
      );

      expect(find.text('PharmaFind', findRichText: true), findsOneWidget);
      expect(find.text(AppStrings.get('tagline', 'en')), findsOneWidget);

      // Unmount so the splash screen's navigation timer ends without a route.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('waits when authentication is still loading and does not navigate prematurely', (tester) async {
      SharedPreferences.setMockInitialValues({'hasSeenOnboarding': true});
      final prefs = await SharedPreferences.getInstance();
      final settings = buildTestSettingsCubit(prefs);
      await settings.markOnboardingSeen();
      final delayedAuth = _DelayedAuthDataSource();

      await tester.pumpWidget(
        withPartnerTestProviders(
          settingsCubit: settings,
          authDataSource: delayedAuth,
          child: MaterialApp(
            routes: {
              AuthRoutes.login: (_) => const Scaffold(key: Key('login_target')),
              AuthRoutes.home: (_) => const Scaffold(key: Key('home_target')),
              AuthRoutes.language: (_) => const Scaffold(key: Key('language_target')),
            },
            home: const SplashScreen(),
          ),
        ),
      );

      // Advance past the 3-second splash animation
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 500));

      // Auth is still unresolved, so splash screen remains on screen
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byKey(const Key('login_target')), findsNothing);

      // Now resolve authentication as unauthenticated
      delayedAuth.completer.complete(null);
      await tester.pumpAndSettle();

      // Now navigates to login
      expect(find.byKey(const Key('login_target')), findsOneWidget);
    });

    testWidgets('routes to /login when user is unauthenticated', (tester) async {
      SharedPreferences.setMockInitialValues({'hasSeenOnboarding': true});
      final prefs = await SharedPreferences.getInstance();
      final settings = buildTestSettingsCubit(prefs);
      await settings.markOnboardingSeen();

      await tester.pumpWidget(
        withPartnerTestProviders(
          settingsCubit: settings,
          authDataSource: _FixedAuthDataSource(null),
          child: MaterialApp(
            routes: {
              AuthRoutes.login: (_) => const Scaffold(key: Key('login_target')),
              AuthRoutes.home: (_) => const Scaffold(key: Key('home_target')),
              AuthRoutes.language: (_) => const Scaffold(key: Key('language_target')),
            },
            home: const SplashScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('login_target')), findsOneWidget);
      expect(find.byKey(const Key('home_target')), findsNothing);
    });

    testWidgets('routes directly to /home when ordinary user is authenticated', (tester) async {
      SharedPreferences.setMockInitialValues({'hasSeenOnboarding': true});
      final prefs = await SharedPreferences.getInstance();
      final settings = buildTestSettingsCubit(prefs);
      await settings.markOnboardingSeen();

      final patientUser = UserModel(
        uid: 'patient-123',
        email: 'patient@example.com',
        displayName: 'John Doe',
        role: 'patient',
        createdAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
        withPartnerTestProviders(
          settingsCubit: settings,
          authDataSource: _FixedAuthDataSource(patientUser),
          child: MaterialApp(
            routes: {
              AuthRoutes.login: (_) => const Scaffold(key: Key('login_target')),
              AuthRoutes.home: (_) => const Scaffold(key: Key('home_target')),
              AuthRoutes.language: (_) => const Scaffold(key: Key('language_target')),
            },
            home: const SplashScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home_target')), findsOneWidget);
      expect(find.byKey(const Key('login_target')), findsNothing);
    });

    testWidgets('routes directly to partner status destination when partner is authenticated', (tester) async {
      SharedPreferences.setMockInitialValues({'hasSeenOnboarding': true});
      final prefs = await SharedPreferences.getInstance();
      final settings = buildTestSettingsCubit(prefs);
      await settings.markOnboardingSeen();

      final partnerUser = UserModel(
        uid: 'partner-999',
        email: 'partner@example.com',
        displayName: 'Dr. Jane',
        role: 'partner',
        createdAt: DateTime(2026, 1, 1),
      );

      final pharmacyDataSource = MockPharmacyDataSource(seedInitialData: false);
      await pharmacyDataSource.createPharmacy(
        PharmacyModel(
          id: 'pharm-approved-999',
          name: 'Jane Pharmacy',
          area: 'Kacyiru',
          district: 'Gasabo',
          phone: '+250788111222',
          email: 'jane@pharm.rw',
          hours: '8:00 AM - 10:00 PM',
          latitude: -1.94,
          longitude: 30.06,
          ownerId: 'partner-999',
          status: 'approved',
          createdAt: DateTime(2026, 1, 1),
          submittedAt: DateTime(2026, 1, 2),
          licenseUrl: 'https://res.cloudinary.com/demo/raw/upload/lic.pdf',
          licensePublicId: 'lic_pub',
          rmohCertUrl: 'https://res.cloudinary.com/demo/raw/upload/rmoh.pdf',
          rmohCertPublicId: 'rmoh_pub',
        ),
      );

      await tester.pumpWidget(
        withPartnerTestProviders(
          settingsCubit: settings,
          authDataSource: _FixedAuthDataSource(partnerUser),
          pharmacyDataSource: pharmacyDataSource,
          child: MaterialApp(
            routes: {
              AuthRoutes.login: (_) => const Scaffold(key: Key('login_target')),
              AuthRoutes.partnerDashboard: (_) => const Scaffold(key: Key('partner_dashboard_target')),
              AuthRoutes.language: (_) => const Scaffold(key: Key('language_target')),
            },
            home: const SplashScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('partner_dashboard_target')), findsOneWidget);
      expect(find.byKey(const Key('login_target')), findsNothing);
    });
  });
}
