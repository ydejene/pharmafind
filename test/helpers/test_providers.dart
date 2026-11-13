import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmafind/data/datasources/auth_datasource.dart';
import 'package:pharmafind/data/datasources/mock_alert_datasource.dart';
import 'package:pharmafind/data/datasources/mock_auth_datasource.dart';
import 'package:pharmafind/data/datasources/mock_pharmacy_datasource.dart';
import 'package:pharmafind/data/datasources/shared_preferences_settings_datasource.dart';
import 'package:pharmafind/data/repositories/alert_repository_impl.dart';
import 'package:pharmafind/data/repositories/auth_repository_impl.dart';
import 'package:pharmafind/data/repositories/pharmacy_repository_impl.dart';
import 'package:pharmafind/data/repositories/settings_repository_impl.dart';
import 'package:pharmafind/domain/usecases/alert/create_alert_usecase.dart';
import 'package:pharmafind/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:pharmafind/domain/usecases/auth/register_with_email_usecase.dart';
import 'package:pharmafind/domain/usecases/auth/send_password_reset_usecase.dart';
import 'package:pharmafind/domain/usecases/auth/sign_in_with_email_usecase.dart';
import 'package:pharmafind/domain/usecases/auth/sign_in_with_google_usecase.dart';
import 'package:pharmafind/domain/usecases/auth/sign_out_usecase.dart';
import 'package:pharmafind/domain/usecases/auth/update_user_profile_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/add_stock_item_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/create_pharmacy_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/delete_stock_item_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/get_pharmacy_by_owner_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/get_pharmacy_stock_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/search_medicine_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/update_pharmacy_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/update_stock_item_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/watch_pharmacy_stock_usecase.dart';
import 'package:pharmafind/domain/usecases/settings/get_settings_usecase.dart';
import 'package:pharmafind/domain/usecases/settings/mark_onboarding_seen_usecase.dart';
import 'package:pharmafind/domain/usecases/settings/set_app_updates_usecase.dart';
import 'package:pharmafind/domain/usecases/settings/set_dark_mode_usecase.dart';
import 'package:pharmafind/domain/usecases/settings/set_locale_usecase.dart';
import 'package:pharmafind/domain/usecases/settings/set_stock_alerts_usecase.dart';
import 'package:pharmafind/presentation/bloc/alert/alert_cubit.dart';
import 'package:pharmafind/presentation/bloc/auth/auth_bloc.dart';
import 'package:pharmafind/presentation/bloc/auth/auth_event.dart';
import 'package:pharmafind/presentation/bloc/pharmacy/pharmacy_cubit.dart';
import 'package:pharmafind/presentation/bloc/search/search_cubit.dart';
import 'package:pharmafind/presentation/bloc/settings/settings_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

SettingsCubit buildSettingsCubit(SharedPreferences prefs) {
  final repository = SettingsRepositoryImpl(
    localDataSource: SharedPreferencesSettingsDataSource(prefs: prefs),
  );
  return SettingsCubit(
    getSettings: GetSettingsUseCase(repository),
    setLocaleUseCase: SetLocaleUseCase(repository),
    setDarkModeUseCase: SetDarkModeUseCase(repository),
    setStockAlertsUseCase: SetStockAlertsUseCase(repository),
    setAppUpdatesUseCase: SetAppUpdatesUseCase(repository),
    markOnboardingSeenUseCase: MarkOnboardingSeenUseCase(repository),
  );
}

/// Wraps [child] in the same providers as `main.dart`, using the mock data
/// sources unless a test passes its own.
Widget withTestProviders({
  required SettingsCubit settingsCubit,
  required Widget child,
  IAuthDataSource? authDataSource,
}) {
  final authRepository = AuthRepositoryImpl(
    datasource: authDataSource ?? MockAuthDataSource(),
  );
  final pharmacyRepository = PharmacyRepositoryImpl(
    datasource: MockPharmacyDataSource(),
  );
  final alertRepository = AlertRepositoryImpl(
    datasource: MockAlertDataSource(),
  );

  return MultiBlocProvider(
    providers: [
      BlocProvider<SettingsCubit>.value(value: settingsCubit),
      BlocProvider<AuthBloc>(
        create: (_) => AuthBloc(
          getCurrentUser: GetCurrentUserUseCase(authRepository),
          signInWithEmail: SignInWithEmailUseCase(authRepository),
          registerWithEmail: RegisterWithEmailUseCase(authRepository),
          signInWithGoogle: SignInWithGoogleUseCase(authRepository),
          sendPasswordReset: SendPasswordResetUseCase(authRepository),
          signOut: SignOutUseCase(authRepository),
          updateUserProfile: UpdateUserProfileUseCase(authRepository),
        )..add(AuthCheckRequested()),
      ),
      BlocProvider<SearchCubit>(
        create: (_) => SearchCubit(
          searchMedicineUseCase: SearchMedicineUseCase(pharmacyRepository),
        ),
      ),
      BlocProvider<PharmacyCubit>(
        create: (_) => PharmacyCubit(
          getPharmacyByOwnerUseCase: GetPharmacyByOwnerUseCase(
            pharmacyRepository,
          ),
          getPharmacyStockUseCase: GetPharmacyStockUseCase(pharmacyRepository),
          createPharmacyUseCase: CreatePharmacyUseCase(pharmacyRepository),
          updatePharmacyUseCase: UpdatePharmacyUseCase(pharmacyRepository),
          addStockItemUseCase: AddStockItemUseCase(pharmacyRepository),
          updateStockItemUseCase: UpdateStockItemUseCase(pharmacyRepository),
          deleteStockItemUseCase: DeleteStockItemUseCase(pharmacyRepository),
          watchPharmacyStockUseCase: WatchPharmacyStockUseCase(
            pharmacyRepository,
          ),
        ),
      ),
      BlocProvider<AlertCubit>(
        create: (_) =>
            AlertCubit(createAlertUseCase: CreateAlertUseCase(alertRepository)),
      ),
    ],
    child: child,
  );
}
