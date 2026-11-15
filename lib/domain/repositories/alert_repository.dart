import '../entities/alert_entity.dart';

abstract class IAlertRepository {
  Future<String> createAlert(AlertEntity alert);
  Future<List<AlertEntity>> getUserAlerts(String userId);
  Future<void> deactivateAlert(String alertId);
  Future<void> deleteAlert(String alertId);
}
