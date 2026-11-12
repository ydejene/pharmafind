import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/pharmacy_model.dart';
import '../models/stock_item_model.dart';
import 'pharmacy_datasource.dart';

class FirestorePharmacyDataSource implements IPharmacyDataSource {
  final FirebaseFirestore _firestore;

  FirestorePharmacyDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _pharmacies =>
      _firestore.collection('pharmacies');

  CollectionReference<Map<String, dynamic>> get _stock =>
      _firestore.collection('stock');

  @override
  Future<String> createPharmacy(PharmacyModel pharmacy) async {
    final reference = pharmacy.id.isEmpty
        ? _pharmacies.doc()
        : _pharmacies.doc(pharmacy.id);
    await reference.set(pharmacy.toMap());
    return reference.id;
  }

  @override
  Future<void> updatePharmacy(PharmacyModel pharmacy) {
    return _pharmacies
        .doc(pharmacy.id)
        .set(pharmacy.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> deletePharmacy(String pharmacyId) async {
    final stockSnapshot = await _stock
        .where('pharmacyId', isEqualTo: pharmacyId)
        .get();
    final batch = _firestore.batch();
    for (final document in stockSnapshot.docs) {
      batch.delete(document.reference);
    }
    batch.delete(_pharmacies.doc(pharmacyId));
    await batch.commit();
  }

  @override
  Future<PharmacyModel?> getPharmacy(String pharmacyId) async {
    final snapshot = await _pharmacies.doc(pharmacyId).get();
    return snapshot.exists && snapshot.data() != null
        ? PharmacyModel.fromMap(snapshot.data()!, snapshot.id)
        : null;
  }

  @override
  Future<List<PharmacyModel>> getApprovedPharmacies() async {
    final snapshot = await _pharmacies
        .where('status', isEqualTo: 'approved')
        .orderBy('name')
        .get();
    return snapshot.docs
        .map((document) => PharmacyModel.fromMap(document.data(), document.id))
        .toList();
  }

  @override
  Future<PharmacyModel?> getPharmacyByOwner(String ownerId) async {
    final snapshot = await _pharmacies
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .get();
    return snapshot.docs.isEmpty
        ? null
        : PharmacyModel.fromMap(
            snapshot.docs.first.data(),
            snapshot.docs.first.id,
          );
  }

  @override
  Future<List<StockItemModel>> searchMedicine(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return [];

    final snapshot = await _stock
        .where('medicineNameLower', isGreaterThanOrEqualTo: normalized)
        .where('medicineNameLower', isLessThanOrEqualTo: '$normalized\uf8ff')
        .orderBy('medicineNameLower')
        .get();
    return snapshot.docs
        .map((document) => StockItemModel.fromMap(document.data(), document.id))
        .where((item) => item.status != 'out_of_stock')
        .toList();
  }

  @override
  Future<String> addStockItem(StockItemModel item) async {
    final reference = item.id.isEmpty ? _stock.doc() : _stock.doc(item.id);
    await reference.set(_stockData(item));
    return reference.id;
  }

  @override
  Future<void> updateStockItem(StockItemModel item) {
    return _stock.doc(item.id).set(_stockData(item), SetOptions(merge: true));
  }

  @override
  Future<void> deleteStockItem(String stockId) {
    return _stock.doc(stockId).delete();
  }

  @override
  Future<List<StockItemModel>> getPharmacyStock(String pharmacyId) async {
    final snapshot = await _stock
        .where('pharmacyId', isEqualTo: pharmacyId)
        .orderBy('medicineName')
        .get();
    return snapshot.docs
        .map((document) => StockItemModel.fromMap(document.data(), document.id))
        .toList();
  }

  @override
  Stream<List<StockItemModel>> watchPharmacyStock(String pharmacyId) {
    return _stock
        .where('pharmacyId', isEqualTo: pharmacyId)
        .orderBy('medicineName')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) =>
                    StockItemModel.fromMap(document.data(), document.id),
              )
              .toList(),
        );
  }

  Map<String, dynamic> _stockData(StockItemModel item) {
    return {
      ...item.toMap(),
      'medicineNameLower': item.medicineName.trim().toLowerCase(),
    };
  }
}
