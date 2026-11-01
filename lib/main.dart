import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/datasources/mock_auth_datasource.dart';
import 'data/datasources/shared_preferences_settings_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'domain/usecases/auth/get_current_user_usecase.dart';
import 'domain/usecases/auth/register_with_email_usecase.dart';
import 'domain/usecases/auth/send_password_reset_usecase.dart';
import 'domain/usecases/auth/sign_in_with_email_usecase.dart';
import 'domain/usecases/auth/sign_in_with_google_usecase.dart';
import 'domain/usecases/auth/sign_out_usecase.dart';
import 'domain/usecases/auth/update_user_profile_usecase.dart';
import 'domain/usecases/settings/get_settings_usecase.dart';
import 'domain/usecases/settings/mark_onboarding_seen_usecase.dart';
import 'domain/usecases/settings/set_app_updates_usecase.dart';
import 'domain/usecases/settings/set_dark_mode_usecase.dart';
import 'domain/usecases/settings/set_locale_usecase.dart';
import 'domain/usecases/settings/set_stock_alerts_usecase.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'presentation/bloc/settings/settings_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Await SharedPreferences initialization once at app startup
  final sharedPreferences = await SharedPreferences.getInstance();

  // 2. Wire Settings infrastructure and domain layers
  final settingsLocalDataSource = SharedPreferencesSettingsDataSource(
    prefs: sharedPreferences,
  );
  final settingsRepository = SettingsRepositoryImpl(
    localDataSource: settingsLocalDataSource,
  );

  final getSettingsUseCase = GetSettingsUseCase(settingsRepository);
  final setLocaleUseCase = SetLocaleUseCase(settingsRepository);
  final setDarkModeUseCase = SetDarkModeUseCase(settingsRepository);
  final setStockAlertsUseCase = SetStockAlertsUseCase(settingsRepository);
  final setAppUpdatesUseCase = SetAppUpdatesUseCase(settingsRepository);
  final markOnboardingSeenUseCase = MarkOnboardingSeenUseCase(
    settingsRepository,
  );

  // 3. Construct SettingsCubit: initial read is synchronous from the already-loaded prefs
  final settingsCubit = SettingsCubit(
    getSettings: getSettingsUseCase,
    setLocaleUseCase: setLocaleUseCase,
    setDarkModeUseCase: setDarkModeUseCase,
    setStockAlertsUseCase: setStockAlertsUseCase,
    setAppUpdatesUseCase: setAppUpdatesUseCase,
    markOnboardingSeenUseCase: markOnboardingSeenUseCase,
  );

  // 4. Wire Auth infrastructure and domain layers
  final authDataSource = MockAuthDataSource();
  final authRepository = AuthRepositoryImpl(datasource: authDataSource);
  final authBloc = AuthBloc(
    getCurrentUser: GetCurrentUserUseCase(authRepository),
    signInWithEmail: SignInWithEmailUseCase(authRepository),
    registerWithEmail: RegisterWithEmailUseCase(authRepository),
    signInWithGoogle: SignInWithGoogleUseCase(authRepository),
    sendPasswordReset: SendPasswordResetUseCase(authRepository),
    signOut: SignOutUseCase(authRepository),
    updateUserProfile: UpdateUserProfileUseCase(authRepository),
  )..add(AuthCheckRequested());

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
        BlocProvider<AuthBloc>.value(value: authBloc),
      ],
      child: const PharmaFindApp(),
    ),
  );
}
