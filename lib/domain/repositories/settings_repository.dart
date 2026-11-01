import '../entities/settings_entity.dart';

abstract class ISettingsRepository {
  SettingsEntity getSettings();
  Future<void> setLocale(String locale);
  Future<void> setDarkMode(bool isDarkMode);
  Future<void> setStockAlerts(bool stockAlerts);
  Future<void> setAppUpdates(bool appUpdates);
  Future<void> markOnboardingSeen();
}
