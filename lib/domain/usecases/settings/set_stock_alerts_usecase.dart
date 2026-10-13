import '../../repositories/settings_repository.dart';

class SetStockAlertsUseCase {
  final ISettingsRepository repository;

  SetStockAlertsUseCase(this.repository);

  Future<void> call(bool stockAlerts) {
    return repository.setStockAlerts(stockAlerts);
  }
}
