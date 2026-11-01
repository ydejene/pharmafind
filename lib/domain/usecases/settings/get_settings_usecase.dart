import '../../entities/settings_entity.dart';
import '../../repositories/settings_repository.dart';

class GetSettingsUseCase {
  final ISettingsRepository repository;

  GetSettingsUseCase(this.repository);

  SettingsEntity call() {
    return repository.getSettings();
  }
}
