import '../models/alert_model.dart';
import 'alert_datasource.dart';

class MockAlertDataSource implements IAlertDataSource {
  final List<AlertModel> _alerts = [];
  int _counter = 1;

  @override
  Future<String> createAlert(AlertModel alert) async {
    final id = 'alert-${_counter++}';
    final saved = alert.copyWith(id: id);
    _alerts.add(saved);
    return id;
  }

  @override
  Future<List<AlertModel>> getUserAlerts(String userId) async {
    return _alerts.where((a) => a.userId == userId).toList();
  }

  @override
  Future<void> deactivateAlert(String alertId) async {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      _alerts[index] = _alerts[index].copyWith(isActive: false);
    }
  }

  @override
  Future<void> deleteAlert(String alertId) async {
    _alerts.removeWhere((a) => a.id == alertId);
  }
}
