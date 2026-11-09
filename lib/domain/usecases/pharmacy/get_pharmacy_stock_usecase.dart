import '../../entities/stock_item_entity.dart';
import '../../repositories/pharmacy_repository.dart';

class GetPharmacyStockUseCase {
  final IPharmacyRepository repository;

  GetPharmacyStockUseCase(this.repository);

  Future<List<StockItemEntity>> call(String pharmacyId) {
    return repository.getPharmacyStock(pharmacyId);
  }
}

