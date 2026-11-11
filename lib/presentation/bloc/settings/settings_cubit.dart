import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/settings_entity.dart';
import '../../../domain/usecases/settings/get_settings_usecase.dart';
import '../../../domain/usecases/settings/mark_onboarding_seen_usecase.dart';
import '../../../domain/usecases/settings/set_app_updates_usecase.dart';
import '../../../domain/usecases/settings/set_dark_mode_usecase.dart';
import '../../../domain/usecases/settings/set_locale_usecase.dart';
import '../../../domain/usecases/settings/set_stock_alerts_usecase.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SetLocaleUseCase setLocaleUseCase;
  final SetDarkModeUseCase setDarkModeUseCase;
  final SetStockAlertsUseCase setStockAlertsUseCase;
  final SetAppUpdatesUseCase setAppUpdatesUseCase;
  final MarkOnboardingSeenUseCase markOnboardingSeenUseCase;

  SettingsCubit({
    required GetSettingsUseCase getSettings,
    required this.setLocaleUseCase,
    required this.setDarkModeUseCase,
    required this.setStockAlertsUseCase,
    required this.setAppUpdatesUseCase,
    required this.markOnboardingSeenUseCase,
  }) : super(_initialState(getSettings()));

  static SettingsState _initialState(SettingsEntity entity) {
    return SettingsState(
      locale: entity.locale,
      isDarkMode: entity.isDarkMode,
      stockAlerts: entity.stockAlerts,
      appUpdates: entity.appUpdates,
      hasSeenOnboarding: entity.hasSeenOnboarding,
    );
  }

  Future<void> setLocale(String locale) async {
    await setLocaleUseCase(locale);
    emit(state.copyWith(locale: locale));
  }

  Future<void> setDarkMode(bool value) async {
    await setDarkModeUseCase(value);
    emit(state.copyWith(isDarkMode: value));
  }

  Future<void> setStockAlerts(bool value) async {
    await setStockAlertsUseCase(value);
    emit(state.copyWith(stockAlerts: value));
  }

  Future<void> setAppUpdates(bool value) async {
    await setAppUpdatesUseCase(value);
    emit(state.copyWith(appUpdates: value));
  }

  Future<void> markOnboardingSeen() async {
    await markOnboardingSeenUseCase();
    emit(state.copyWith(hasSeenOnboarding: true));
  }
}
