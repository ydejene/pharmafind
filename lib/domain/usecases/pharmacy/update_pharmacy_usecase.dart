import '../../entities/pharmacy_entity.dart';
import '../../repositories/pharmacy_repository.dart';

class UpdatePharmacyUseCase {
  final IPharmacyRepository repository;

  UpdatePharmacyUseCase(this.repository);

  Future<void> call(PharmacyEntity pharmacy) {
    return repository.updatePharmacy(pharmacy);
  }
}

