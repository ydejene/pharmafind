import 'dart:typed_data';

import '../../entities/pharmacy_entity.dart';
import '../../repositories/pharmacy_repository.dart';

class SubmitVerificationDocumentsUseCase {
  final IPharmacyRepository repository;

  SubmitVerificationDocumentsUseCase(this.repository);

  Future<PharmacyEntity> call({
    required String pharmacyId,
    required Uint8List licenseBytes,
    required String licenseFilename,
    required Uint8List rmohBytes,
    required String rmohFilename,
  }) {
    return repository.submitVerificationDocuments(
      pharmacyId: pharmacyId,
      licenseBytes: licenseBytes,
      licenseFilename: licenseFilename,
      rmohBytes: rmohBytes,
      rmohFilename: rmohFilename,
    );
  }
}

