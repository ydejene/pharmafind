import 'package:pharma_find/data/datasources/shared_preferences_settings_datasource.dart';
import 'package:pharma_find/data/repositories/settings_repository_impl.dart';
import 'package:pharma_find/domain/usecases/settings/get_settings_usecase.dart';
import 'package:pharma_find/domain/usecases/settings/mark_onboarding_seen_usecase.dart';
import 'package:pharma_find/domain/usecases/settings/set_app_updates_usecase.dart';
import 'package:pharma_find/domain/usecases/settings/set_dark_mode_usecase.dart';
import 'package:pharma_find/domain/usecases/settings/set_locale_usecase.dart';
import 'package:pharma_find/domain/usecases/settings/set_stock_alerts_usecase.dart';
import 'package:pharma_find/presentation/bloc/settings/settings_cubit.dart';
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
