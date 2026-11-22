import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmafind/data/datasources/auth_datasource.dart';
import 'package:pharmafind/data/datasources/cloudinary_datasource.dart';
import 'package:pharmafind/data/datasources/mock_auth_datasource.dart';
import 'package:pharmafind/data/datasources/mock_cloudinary_datasource.dart';
import 'package:pharmafind/data/datasources/mock_pharmacy_datasource.dart';
import 'package:pharmafind/data/datasources/pharmacy_datasource.dart';
import 'package:pharmafind/data/datasources/shared_preferences_settings_datasource.dart';
import 'package:pharmafind/data/repositories/auth_repository_impl.dart';
import 'package:pharmafind/data/repositories/pharmacy_repository_impl.dart';
import 'package:pharmafind/data/repositories/settings_repository_impl.dart';
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
import 'package:pharmafind/domain/usecases/pharmacy/submit_verification_documents_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/update_pharmacy_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/update_stock_item_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/watch_pharmacy_stock_usecase.dart';
import 'package:pharmafind/domain/usecases/settings/get_settings_usecase.dart';
import 'package:pharmafind/domain/usecases/settings/mark_onboarding_seen_usecase.dart';
import 'package:pharmafind/domain/usecases/settings/set_app_updates_usecase.dart';
import 'package:pharmafind/domain/usecases/settings/set_dark_mode_usecase.dart';
import 'package:pharmafind/domain/usecases/settings/set_locale_usecase.dart';
import 'package:pharmafind/domain/usecases/settings/set_stock_alerts_usecase.dart';
import 'package:pharmafind/presentation/bloc/auth/auth_bloc.dart';
import 'package:pharmafind/presentation/bloc/auth/auth_event.dart';
import 'package:pharmafind/presentation/bloc/pharmacy/pharmacy_cubit.dart';
import 'package:pharmafind/presentation/bloc/settings/settings_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

SettingsCubit buildTestSettingsCubit(SharedPreferences prefs) {
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

Widget withPartnerTestProviders({
  required SettingsCubit settingsCubit,
  required Widget child,
  IAuthDataSource? authDataSource,
  IPharmacyDataSource? pharmacyDataSource,
  ICloudinaryDataSource? cloudinaryDataSource,
  PharmacyCubit? pharmacyCubit,
}) {
  final authRepository = AuthRepositoryImpl(
    datasource: authDataSource ?? MockAuthDataSource(),
  );

  final pDataSource = pharmacyDataSource ?? MockPharmacyDataSource();
  final cDataSource = cloudinaryDataSource ?? MockCloudinaryDataSource();
  final pharmacyRepository = PharmacyRepositoryImpl(
    datasource: pDataSource,
    cloudinaryDatasource: cDataSource,
  );

  final defaultPharmacyCubit = PharmacyCubit(
    getPharmacyByOwnerUseCase: GetPharmacyByOwnerUseCase(pharmacyRepository),
    getPharmacyStockUseCase: GetPharmacyStockUseCase(pharmacyRepository),
    createPharmacyUseCase: CreatePharmacyUseCase(pharmacyRepository),
    updatePharmacyUseCase: UpdatePharmacyUseCase(pharmacyRepository),
    addStockItemUseCase: AddStockItemUseCase(pharmacyRepository),
    updateStockItemUseCase: UpdateStockItemUseCase(pharmacyRepository),
    deleteStockItemUseCase: DeleteStockItemUseCase(pharmacyRepository),
    watchPharmacyStockUseCase: WatchPharmacyStockUseCase(pharmacyRepository),
    submitVerificationDocumentsUseCase:
        SubmitVerificationDocumentsUseCase(pharmacyRepository),
  );

  return MultiBlocProvider(
    providers: [
      BlocProvider<SettingsCubit>.value(value: settingsCubit),
      BlocProvider<AuthBloc>(
        lazy: false,
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
      if (pharmacyCubit != null)
        BlocProvider<PharmacyCubit>.value(value: pharmacyCubit)
      else
        BlocProvider<PharmacyCubit>.value(value: defaultPharmacyCubit),
    ],
    child: child,
  );
}
