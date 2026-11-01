import '../../repositories/settings_repository.dart';

class SetAppUpdatesUseCase {
  final ISettingsRepository repository;

  SetAppUpdatesUseCase(this.repository);

  Future<void> call(bool appUpdates) {
    return repository.setAppUpdates(appUpdates);
  }
}
