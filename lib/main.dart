import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/datasources/firebase_auth_datasource.dart';
import 'data/datasources/firestore_pharmacy_datasource.dart';
import 'data/datasources/shared_preferences_settings_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/pharmacy_repository_impl.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'domain/repositories/pharmacy_repository.dart';
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
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final sharedPreferences = await SharedPreferences.getInstance();

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

  final settingsCubit = SettingsCubit(
    getSettings: getSettingsUseCase,
    setLocaleUseCase: setLocaleUseCase,
    setDarkModeUseCase: setDarkModeUseCase,
    setStockAlertsUseCase: setStockAlertsUseCase,
    setAppUpdatesUseCase: setAppUpdatesUseCase,
    markOnboardingSeenUseCase: markOnboardingSeenUseCase,
  );

  final authDataSource = FirebaseAuthDataSource();
  final authRepository = AuthRepositoryImpl(datasource: authDataSource);
  final pharmacyRepository = PharmacyRepositoryImpl(
    datasource: FirestorePharmacyDataSource(),
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

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
        BlocProvider<AuthBloc>.value(value: authBloc),
        RepositoryProvider<IPharmacyRepository>.value(
          value: pharmacyRepository,
        ),
      ],
      child: const PharmaFindApp(),
    ),
  );
}
