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
}
