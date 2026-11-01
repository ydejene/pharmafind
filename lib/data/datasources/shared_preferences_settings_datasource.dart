import 'package:shared_preferences/shared_preferences.dart';

import 'settings_local_datasource.dart';

class SharedPreferencesSettingsDataSource implements ISettingsLocalDataSource {
  final SharedPreferences prefs;

  SharedPreferencesSettingsDataSource({required this.prefs});

  @override
  String getLocale() => prefs.getString('locale') ?? 'en';

  @override
  Future<void> setLocale(String locale) => prefs.setString('locale', locale);

  @override
  bool isDarkMode() => prefs.getBool('isDarkMode') ?? false;

  @override
  Future<void> setDarkMode(bool value) => prefs.setBool('isDarkMode', value);

  @override
  bool getStockAlerts() => prefs.getBool('stockAlerts') ?? true;

  @override
  Future<void> setStockAlerts(bool value) =>
      prefs.setBool('stockAlerts', value);

  @override
  bool getAppUpdates() => prefs.getBool('appUpdates') ?? false;

  @override
  Future<void> setAppUpdates(bool value) => prefs.setBool('appUpdates', value);

  @override
  bool hasSeenOnboarding() => prefs.getBool('hasSeenOnboarding') ?? false;

  @override
  Future<void> setHasSeenOnboarding(bool value) =>
      prefs.setBool('hasSeenOnboarding', value);
}
