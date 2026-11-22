import 'dart:typed_data';

import '../entities/pharmacy_entity.dart';
import '../entities/stock_item_entity.dart';

abstract class IPharmacyRepository {
  Future<String> createPharmacy(PharmacyEntity pharmacy);
  Future<void> updatePharmacy(PharmacyEntity pharmacy);
  Future<void> deletePharmacy(String pharmacyId);
  Future<PharmacyEntity?> getPharmacy(String pharmacyId);
  Future<List<PharmacyEntity>> getApprovedPharmacies();
  Future<PharmacyEntity?> getPharmacyByOwner(String ownerId);
  Future<List<StockItemEntity>> searchMedicine(String query);
  Future<String> addStockItem(StockItemEntity item);
  Future<void> updateStockItem(StockItemEntity item);
  Future<void> deleteStockItem(String stockId);
  Future<List<StockItemEntity>> getPharmacyStock(String pharmacyId);
  Stream<List<StockItemEntity>> watchPharmacyStock(String pharmacyId);

  /// Uploads replacement licence and/or RMOH certificate documents to Cloudinary,
  /// updates the pharmacy record with URLs and submission timestamp,
  /// and returns the updated [PharmacyEntity].
  Future<PharmacyEntity> submitVerificationDocuments({
    required String pharmacyId,
    Uint8List? licenseBytes,
    String? licenseFilename,
    Uint8List? rmohBytes,
    String? rmohFilename,
  });
}
