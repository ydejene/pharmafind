import 'dart:typed_data';

import '../../entities/pharmacy_entity.dart';
import '../../repositories/pharmacy_repository.dart';

class SubmitVerificationDocumentsUseCase {
  final IPharmacyRepository repository;

  SubmitVerificationDocumentsUseCase(this.repository);

  Future<PharmacyEntity> call({
    required String pharmacyId,
    Uint8List? licenseBytes,
    String? licenseFilename,
    Uint8List? rmohBytes,
    String? rmohFilename,
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

