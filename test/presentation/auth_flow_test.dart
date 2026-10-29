import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_find/app.dart';
import 'package:pharma_find/core/constants/app_strings.dart';
import 'package:pharma_find/data/datasources/auth_datasource.dart';
import 'package:pharma_find/data/datasources/mock_auth_datasource.dart';
import 'package:pharma_find/data/models/user_model.dart';
import 'package:pharma_find/presentation/bloc/settings/settings_cubit.dart';
import 'package:pharma_find/presentation/screens/home/home_screen.dart';
import 'package:pharma_find/presentation/screens/onboarding/login_screen.dart';
import 'package:pharma_find/presentation/screens/onboarding/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_providers.dart';

class _FailingAuthDataSource extends MockAuthDataSource {
  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    throw Exception('Invalid credentials');
  }

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

String _en(String key) => AppStrings.get(key, 'en');

class _RouteCounter extends NavigatorObserver {
  final pushed = <String?>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushed.add(route.settings.name);
  }
}

void main() {
  late SettingsCubit settingsCubit;

  // Boots the real app and waits for the splash screen to hand over.
  Future<void> pumpApp(
    WidgetTester tester, {
    bool seenOnboarding = true,
    IAuthDataSource? dataSource,
    Widget app = const PharmaFindApp(),
  }) async {
    // Wide enough for the test font, whose glyphs overflow phone-width rows.
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settingsCubit = buildSettingsCubit(prefs);
    if (seenOnboarding) await settingsCubit.markOnboardingSeen();

    await tester.pumpWidget(
      withTestProviders(
        settingsCubit: settingsCubit,
        authDataSource: dataSource,
        child: app,
      ),
    );
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  // The mock data source delays its responses by up to 400ms.
  Future<void> settleAuth(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    final target = find.text(text).last;
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> enterFields(WidgetTester tester, List<String> values) async {
    for (var i = 0; i < values.length; i++) {
      await tester.enterText(find.byType(TextFormField).at(i), values[i]);
    }
    await tester.pump();
  }

  void expectOnHomeWithNoWayBack(WidgetTester tester) {
    expect(find.byType(HomeScreen), findsOneWidget);
    final navigator = Navigator.of(tester.element(find.byType(HomeScreen)));
    expect(navigator.canPop(), isFalse);
  }

  group('Language selection and onboarding', () {
    testWidgets('first launch opens language selection', (tester) async {
      await pumpApp(tester, seenOnboarding: false);

      expect(find.text(_en('choose_language')), findsOneWidget);
      expect(find.text('Kinyarwanda'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Français'), findsOneWidget);
    });

    testWidgets('selecting a language translates the screen', (tester) async {
      await pumpApp(tester, seenOnboarding: false);

      await tapText(tester, 'Français');

      expect(settingsCubit.state.locale, 'fr');
      expect(
        find.text(AppStrings.get('choose_language', 'fr')),
        findsOneWidget,
      );
    });

    testWidgets('continue marks onboarding seen and opens login', (
      tester,
    ) async {
      await pumpApp(tester, seenOnboarding: false);

      await tapText(tester, _en('continue_btn'));

      expect(settingsCubit.state.hasSeenOnboarding, isTrue);
      expect(find.text(_en('login')), findsOneWidget);
    });

    testWidgets('returning user goes straight to login', (tester) async {
      await pumpApp(tester);

      expect(find.text(_en('login')), findsOneWidget);
    });
  });

  group('Language selection and onboarding', () {
    testWidgets('first launch opens language selection', (tester) async {
      await pumpApp(tester, seenOnboarding: false);

      expect(find.text(_en('choose_language')), findsOneWidget);
      expect(find.text('Kinyarwanda'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Français'), findsOneWidget);
    });
  });
}
