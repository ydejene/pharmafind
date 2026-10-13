import '../../repositories/settings_repository.dart';

class SetLocaleUseCase {
  final ISettingsRepository repository;

  SetLocaleUseCase(this.repository);

  Future<void> call(String locale) {
    return repository.setLocale(locale);
  }
}
