import '../../entities/pharmacy_entity.dart';
import '../../repositories/pharmacy_repository.dart';

class GetPharmacyByOwnerUseCase {
  final IPharmacyRepository repository;

  GetPharmacyByOwnerUseCase(this.repository);

  Future<PharmacyEntity?> call(String ownerId) {
    return repository.getPharmacyByOwner(ownerId);
  }
}

