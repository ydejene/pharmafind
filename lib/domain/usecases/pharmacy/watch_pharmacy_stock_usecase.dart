import '../../entities/stock_item_entity.dart';
import '../../repositories/pharmacy_repository.dart';

class WatchPharmacyStockUseCase {
  final IPharmacyRepository repository;

  WatchPharmacyStockUseCase(this.repository);

  Stream<List<StockItemEntity>> call(String pharmacyId) {
    return repository.watchPharmacyStock(pharmacyId);
  }
}

