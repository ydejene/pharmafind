import '../../repositories/settings_repository.dart';

class MarkOnboardingSeenUseCase {
  final ISettingsRepository repository;

  MarkOnboardingSeenUseCase(this.repository);

  Future<void> call() {
    return repository.markOnboardingSeen();
  }
}
