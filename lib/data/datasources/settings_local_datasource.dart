abstract class ISettingsLocalDataSource {
  String getLocale();
  Future<void> setLocale(String locale);
  bool isDarkMode();
  Future<void> setDarkMode(bool value);
  bool getStockAlerts();
  Future<void> setStockAlerts(bool value);
  bool getAppUpdates();
  Future<void> setAppUpdates(bool value);
  bool hasSeenOnboarding();
  Future<void> setHasSeenOnboarding(bool value);
}
