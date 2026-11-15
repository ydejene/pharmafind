import '../../entities/stock_item_entity.dart';
import '../../repositories/pharmacy_repository.dart';

class SearchMedicineUseCase {
  final IPharmacyRepository repository;

  SearchMedicineUseCase(this.repository);

  Future<List<StockItemEntity>> call(String query) {
    return repository.searchMedicine(query);
  }
}
