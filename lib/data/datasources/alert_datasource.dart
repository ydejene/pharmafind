import '../models/alert_model.dart';

abstract class IAlertDataSource {
  Future<String> createAlert(AlertModel alert);
  Future<List<AlertModel>> getUserAlerts(String userId);
  Future<void> deactivateAlert(String alertId);
  Future<void> deleteAlert(String alertId);
}
