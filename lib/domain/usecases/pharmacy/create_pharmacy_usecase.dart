import '../../entities/pharmacy_entity.dart';
import '../../repositories/pharmacy_repository.dart';

class CreatePharmacyUseCase {
  final IPharmacyRepository repository;

  CreatePharmacyUseCase(this.repository);

  Future<String> call(PharmacyEntity pharmacy) {
    return repository.createPharmacy(pharmacy);
  }
}

