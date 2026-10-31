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

  group('Login', () {
    testWidgets('empty form shows validation errors and stays put', (
      tester,
    ) async {
      await pumpApp(tester);

      await tapText(tester, _en('sign_in'));

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });

    testWidgets('valid credentials open home', (tester) async {
      await pumpApp(tester);

      await enterFields(tester, ['user@example.com', 'secret1']);
      await tapText(tester, _en('sign_in'));
      await settleAuth(tester);

      expectOnHomeWithNoWayBack(tester);
    });

    testWidgets('failed sign-in shows the error and stays on login', (
      tester,
    ) async {
      await pumpApp(tester, dataSource: _FailingAuthDataSource());

      await enterFields(tester, ['user@example.com', 'secret1']);
      await tapText(tester, _en('sign_in'));
      await settleAuth(tester);

      expect(find.textContaining('Invalid credentials'), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });

    testWidgets('Google sign-in opens home', (tester) async {
      await pumpApp(tester);

      await tapText(tester, _en('google_sign_in'));
      await settleAuth(tester);

      expectOnHomeWithNoWayBack(tester);
    });

    testWidgets('skip opens home', (tester) async {
      await pumpApp(tester);

      await tapText(tester, _en('skip_for_now'));

      expectOnHomeWithNoWayBack(tester);
    });
  });

  group('Registration', () {
    Future<void> openRegister(WidgetTester tester) async {
      await tapText(tester, _en('sign_up'));
      expect(find.text(_en('register')), findsOneWidget);
    }

    testWidgets('mismatched passwords are rejected', (tester) async {
      await pumpApp(tester);
      await openRegister(tester);

      await enterFields(tester, [
        'Test User',
        'user@example.com',
        'secret1',
        'secret2',
      ]);
      await tapText(tester, _en('sign_up'));

      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });

    testWidgets('valid details open home with login cleared', (tester) async {
      await pumpApp(tester);
      await openRegister(tester);

      await enterFields(tester, [
        'Test User',
        'user@example.com',
        'secret1',
        'secret1',
      ]);
      await tapText(tester, _en('sign_up'));
      await settleAuth(tester);

      expectOnHomeWithNoWayBack(tester);
    });

    testWidgets('failure shows the error and stays on register', (
      tester,
    ) async {
      await pumpApp(tester, dataSource: _FailingAuthDataSource());
      await openRegister(tester);

      await enterFields(tester, [
        'Test User',
        'user@example.com',
        'secret1',
        'secret1',
      ]);
      await tapText(tester, _en('sign_up'));
      await settleAuth(tester);

      expect(find.textContaining('Email already in use'), findsOneWidget);
      expect(find.text(_en('register')), findsOneWidget);
    });

    testWidgets('the login screen underneath does not navigate as well', (
      tester,
    ) async {
      final routes = _RouteCounter();
      await pumpApp(
        tester,
        app: MaterialApp(
          navigatorObservers: [routes],
          home: const LoginScreen(),
          routes: {
            '/register': (_) => const RegisterScreen(),
            '/home': (_) => const Scaffold(),
          },
        ),
      );
      await openRegister(tester);

      await enterFields(tester, [
        'Test User',
        'user@example.com',
        'secret1',
        'secret1',
      ]);
      await tapText(tester, _en('sign_up'));
      await settleAuth(tester);

      expect(routes.pushed.where((name) => name == '/home'), hasLength(1));
    });

    testWidgets('sign-in link returns to the existing login screen', (
      tester,
    ) async {
      await pumpApp(tester);
      await openRegister(tester);

      await tapText(tester, _en('sign_in'));

      expect(find.text(_en('login')), findsOneWidget);
      final navigator = Navigator.of(tester.element(find.text(_en('login'))));
      expect(navigator.canPop(), isFalse);
    });
  });


}
