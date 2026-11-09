import '../../entities/stock_item_entity.dart';
import '../../repositories/pharmacy_repository.dart';

class AddStockItemUseCase {
  final IPharmacyRepository repository;

  AddStockItemUseCase(this.repository);

  Future<String> call(StockItemEntity item) {
    return repository.addStockItem(item);
  }
}

