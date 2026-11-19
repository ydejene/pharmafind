import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/alert_model.dart';
import 'alert_datasource.dart';

class FirestoreAlertDataSource implements IAlertDataSource {
  final FirebaseFirestore _firestore;

  FirestoreAlertDataSource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _alerts {
    return _firestore.collection('alerts');
  }

  @override
  Future<String> createAlert(AlertModel alert) async {
    final medicineName = alert.medicineName.trim().toLowerCase();
    final searchArea = alert.searchArea.trim().toLowerCase();

    // checking the user's saved alerts to prevent duplicates
    final existingAlerts = await _alerts
        .where('userId', isEqualTo: alert.userId)
        .get();

    for (final document in existingAlerts.docs) {
      final data = document.data();

      final savedMedicine = (
          data['medicineNameLower'] ??
              data['medicineName'] ??
              ''
      ).toString().trim().toLowerCase();

      final savedArea = (
          data['searchAreaLower'] ??
              data['searchArea'] ??
              ''
      ).toString().trim().toLowerCase();

      final isActive = data['isActive'] ?? true;

      if (savedMedicine == medicineName &&
          savedArea == searchArea &&
          isActive) {
        return document.id;
      }
    }

    final reference = _alerts.doc();

    // saving the new medicine availability alert
    await reference.set({
      ...alert.toMap(),
      'medicineNameLower': medicineName,
      'searchAreaLower': searchArea,
    });

    return reference.id;
  }

  @override
  Future<List<AlertModel>> getUserAlerts(String userId) async {
    final snapshot = await _alerts
        .where('userId', isEqualTo: userId)
        .get();

    final alerts = snapshot.docs.map((document) {
      return AlertModel.fromMap(
        document.data(),
        document.id,
      );
    }).toList();

    // showing the newest alerts first
    alerts.sort((first, second) {
      return second.createdAt.compareTo(first.createdAt);
    });

    return alerts;
  }

  @override
  Future<void> deactivateAlert(String alertId) {
    return _alerts.doc(alertId).update({
      'isActive': false,
    });
  }

  @override
  Future<void> deleteAlert(String alertId) {
    return _alerts.doc(alertId).delete();
  }
}