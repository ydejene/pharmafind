import '../../repositories/pharmacy_repository.dart';

class DeleteStockItemUseCase {
  final IPharmacyRepository repository;

  DeleteStockItemUseCase(this.repository);

  Future<void> call(String stockId) {
    return repository.deleteStockItem(stockId);
  }
}

