import '../models/alert_model.dart';

class AlertRepository {
  final Map<String, AlertModel> _alerts = {};
  int _idCounter = 1;

  Future<String> createAlert(AlertModel alert) async {
    final id = 'alert-${_idCounter++}';
    _alerts[id] = AlertModel(
      id: id,
      userId: alert.userId,
      medicineName: alert.medicineName,
      searchArea: alert.searchArea,
      createdAt: DateTime.now(),
    );
    return id;
  }

  Future<List<AlertModel>> getUserAlerts(String userId) async {
    return _alerts.values
        .where((a) => a.userId == userId && a.isActive)
        .toList();
  }

  Future<void> deactivateAlert(String alertId) async {
    final existing = _alerts[alertId];
    if (existing != null) {
      _alerts[alertId] = AlertModel(
        id: existing.id,
        userId: existing.userId,
        medicineName: existing.medicineName,
        searchArea: existing.searchArea,
        isActive: false,
        createdAt: existing.createdAt,
      );
    }
  }

  Future<void> deleteAlert(String alertId) async {
    _alerts.remove(alertId);
  }
}
