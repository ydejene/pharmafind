import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements ISettingsRepository {
  final ISettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  SettingsEntity getSettings() {
    return SettingsEntity(
      locale: localDataSource.getLocale(),
      isDarkMode: localDataSource.isDarkMode(),
      stockAlerts: localDataSource.getStockAlerts(),
      appUpdates: localDataSource.getAppUpdates(),
      hasSeenOnboarding: localDataSource.hasSeenOnboarding(),
    );
  }

  @override
  Future<void> setLocale(String locale) => localDataSource.setLocale(locale);

  @override
  Future<void> setDarkMode(bool isDarkMode) =>
      localDataSource.setDarkMode(isDarkMode);

  @override
  Future<void> setStockAlerts(bool stockAlerts) =>
      localDataSource.setStockAlerts(stockAlerts);

  @override
  Future<void> setAppUpdates(bool appUpdates) =>
      localDataSource.setAppUpdates(appUpdates);

  @override
  Future<void> markOnboardingSeen() =>
      localDataSource.setHasSeenOnboarding(true);
}
