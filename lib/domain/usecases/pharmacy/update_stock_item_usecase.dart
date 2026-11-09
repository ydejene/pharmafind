import '../../entities/stock_item_entity.dart';
import '../../repositories/pharmacy_repository.dart';

class UpdateStockItemUseCase {
  final IPharmacyRepository repository;

  UpdateStockItemUseCase(this.repository);

  Future<void> call(StockItemEntity item) {
    return repository.updateStockItem(item);
  }
}

