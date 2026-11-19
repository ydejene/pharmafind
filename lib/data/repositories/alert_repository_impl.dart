import '../../domain/entities/alert_entity.dart';
import '../../domain/repositories/alert_repository.dart';
import '../datasources/alert_datasource.dart';
import '../models/alert_model.dart';

class AlertRepositoryImpl implements IAlertRepository {
  final IAlertDataSource datasource;

  AlertRepositoryImpl({
    required this.datasource,
  });

  @override
  Future<String> createAlert(AlertEntity alert) {
    return datasource.createAlert(
      AlertModel.fromEntity(alert),
    );
  }

  @override
  Future<List<AlertEntity>> getUserAlerts(String userId) async {
    final alerts = await datasource.getUserAlerts(userId);

    return alerts.map((alert) {
      return alert.toEntity();
    }).toList();
  }

  @override
  Future<void> deactivateAlert(String alertId) {
    return datasource.deactivateAlert(alertId);
  }

  @override
  Future<void> deleteAlert(String alertId) {
    return datasource.deleteAlert(alertId);
  }
}