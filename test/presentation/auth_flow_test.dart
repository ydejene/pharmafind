import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmafind/app.dart';
import 'package:pharmafind/core/constants/app_strings.dart';
import 'package:pharmafind/data/datasources/auth_datasource.dart';
import 'package:pharmafind/data/datasources/mock_auth_datasource.dart';
import 'package:pharmafind/data/datasources/shared_preferences_settings_datasource.dart';
import 'package:pharmafind/data/models/user_model.dart';
import 'package:pharmafind/data/repositories/auth_repository_impl.dart';
import 'package:pharmafind/data/repositories/settings_repository_impl.dart';
import 'package:pharmafind/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:pharmafind/domain/usecases/auth/register_with_email_usecase.dart';
import 'package:pharmafind/domain/usecases/auth/send_password_reset_usecase.dart';
import 'package:pharmafind/domain/usecases/auth/sign_in_with_email_usecase.dart';
import 'package:pharmafind/domain/usecases/auth/sign_in_with_google_usecase.dart';
import 'package:pharmafind/domain/usecases/auth/sign_out_usecase.dart';
import 'package:pharmafind/domain/usecases/auth/update_user_profile_usecase.dart';
import 'package:pharmafind/domain/usecases/settings/get_settings_usecase.dart';
import 'package:pharmafind/domain/usecases/settings/mark_onboarding_seen_usecase.dart';
import 'package:pharmafind/domain/usecases/settings/set_app_updates_usecase.dart';
import 'package:pharmafind/domain/usecases/settings/set_dark_mode_usecase.dart';
import 'package:pharmafind/domain/usecases/settings/set_locale_usecase.dart';
import 'package:pharmafind/domain/usecases/settings/set_stock_alerts_usecase.dart';
import 'package:pharmafind/presentation/bloc/auth/auth_bloc.dart';
import 'package:pharmafind/presentation/bloc/auth/auth_event.dart';
import 'package:pharmafind/presentation/bloc/settings/settings_cubit.dart';
import 'package:pharmafind/presentation/screens/onboarding/login_screen.dart';
import 'package:pharmafind/presentation/screens/onboarding/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

const _homeText = 'Home (/home)';

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
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settingsRepository = SettingsRepositoryImpl(
      localDataSource: SharedPreferencesSettingsDataSource(prefs: prefs),
    );
    settingsCubit = SettingsCubit(
      getSettings: GetSettingsUseCase(settingsRepository),
      setLocaleUseCase: SetLocaleUseCase(settingsRepository),
      setDarkModeUseCase: SetDarkModeUseCase(settingsRepository),
      setStockAlertsUseCase: SetStockAlertsUseCase(settingsRepository),
      setAppUpdatesUseCase: SetAppUpdatesUseCase(settingsRepository),
      markOnboardingSeenUseCase: MarkOnboardingSeenUseCase(settingsRepository),
    );
    if (seenOnboarding) await settingsCubit.markOnboardingSeen();

    final authRepository = AuthRepositoryImpl(
      datasource: dataSource ?? MockAuthDataSource(),
    );
    final authBloc = AuthBloc(
      getCurrentUser: GetCurrentUserUseCase(authRepository),
      signInWithEmail: SignInWithEmailUseCase(authRepository),
      registerWithEmail: RegisterWithEmailUseCase(authRepository),
      signInWithGoogle: SignInWithGoogleUseCase(authRepository),
      sendPasswordReset: SendPasswordResetUseCase(authRepository),
      signOut: SignOutUseCase(authRepository),
      updateUserProfile: UpdateUserProfileUseCase(authRepository),
    )..add(AuthCheckRequested());

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<SettingsCubit>.value(value: settingsCubit),
          BlocProvider<AuthBloc>.value(value: authBloc),
        ],
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
    expect(find.text(_homeText), findsOneWidget);
    final navigator = Navigator.of(tester.element(find.text(_homeText)));
    expect(navigator.canPop(), isFalse);
  }

  group('Login', () {
    testWidgets('empty form shows validation errors and stays put', (
      tester,
    ) async {
      await pumpApp(tester);

      await tapText(tester, _en('sign_in'));

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(find.text(_homeText), findsNothing);
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
      expect(find.text(_homeText), findsNothing);
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
      expect(find.text(_homeText), findsNothing);
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
            '/home': (_) => const Scaffold(body: Text(_homeText)),
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

  group('Forgot password', () {
    testWidgets('sends the reset and returns to login', (tester) async {
      await pumpApp(tester);

      await tapText(tester, _en('forgot_password'));
      expect(find.text(_en('forgot_password_sub')), findsOneWidget);

      await enterFields(tester, ['user@example.com']);
      await tapText(tester, _en('continue_btn'));
      await settleAuth(tester);

      expect(find.text(_en('password_reset_sent')), findsOneWidget);

      await tapText(tester, _en('sign_in'));

      expect(find.text(_en('login')), findsOneWidget);
    });

    testWidgets('invalid email is rejected', (tester) async {
      await pumpApp(tester);

      await tapText(tester, _en('forgot_password'));
      await enterFields(tester, ['not-an-email']);
      await tapText(tester, _en('continue_btn'));

      expect(find.text('Please enter a valid email'), findsOneWidget);
      expect(find.text(_en('password_reset_sent')), findsNothing);
    });
  });
}
