import '../models/pharmacy_model.dart';
import '../models/stock_item_model.dart';

abstract class IPharmacyDataSource {
  Future<String> createPharmacy(PharmacyModel pharmacy);
  Future<void> updatePharmacy(PharmacyModel pharmacy);
  Future<void> deletePharmacy(String pharmacyId);
  Future<PharmacyModel?> getPharmacy(String pharmacyId);
  Future<List<PharmacyModel>> getApprovedPharmacies();
  Future<PharmacyModel?> getPharmacyByOwner(String ownerId);
  Future<List<StockItemModel>> searchMedicine(String query);
  Future<String> addStockItem(StockItemModel item);
  Future<void> updateStockItem(StockItemModel item);
  Future<void> deleteStockItem(String stockId);
  Future<List<StockItemModel>> getPharmacyStock(String pharmacyId);
  Stream<List<StockItemModel>> watchPharmacyStock(String pharmacyId);
}
