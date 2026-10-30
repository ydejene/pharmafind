import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences _prefs;

  SettingsCubit({required SharedPreferences prefs})
    : _prefs = prefs,
      super(
        SettingsState(
          locale: prefs.getString('locale') ?? 'en',
          isDarkMode: prefs.getBool('isDarkMode') ?? false,
          stockAlerts: prefs.getBool('stockAlerts') ?? true,
          appUpdates: prefs.getBool('appUpdates') ?? false,
          hasSeenOnboarding: prefs.getBool('hasSeenOnboarding') ?? false,
        ),
      );

  void setLocale(String locale) {
    _prefs.setString('locale', locale);
    emit(state.copyWith(locale: locale));
  }

  void setDarkMode(bool value) {
    _prefs.setBool('isDarkMode', value);
    emit(state.copyWith(isDarkMode: value));
  }

  void setStockAlerts(bool value) {
    _prefs.setBool('stockAlerts', value);
    emit(state.copyWith(stockAlerts: value));
  }

  void setAppUpdates(bool value) {
    _prefs.setBool('appUpdates', value);
    emit(state.copyWith(appUpdates: value));
  }

  void markOnboardingSeen() {
    _prefs.setBool('hasSeenOnboarding', true);
    emit(state.copyWith(hasSeenOnboarding: true));
  }
}
