import '../../repositories/settings_repository.dart';

class SetDarkModeUseCase {
  final ISettingsRepository repository;

  SetDarkModeUseCase(this.repository);

  Future<void> call(bool isDarkMode) {
    return repository.setDarkMode(isDarkMode);
  }
}
