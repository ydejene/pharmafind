import 'package:flutter_test/flutter_test.dart';
import 'package:pharmafind/domain/entities/pharmacy_entity.dart';
import 'package:pharmafind/data/models/pharmacy_model.dart';

void main() {
  group('PharmacyEntity Verification and Rejection Metadata', () {
    test('supports explicit clearing of rejectionReason without losing other metadata', () {
      final original = PharmacyEntity(
        id: 'pharm-1',
        name: 'Test Pharmacy',
        area: 'Remera',
        district: 'Gasabo',
        phone: '+250788111222',
        email: 'test@pharmacy.rw',
        latitude: -1.95,
        longitude: 30.06,
        ownerId: 'owner-1',
        status: 'rejected',
        createdAt: DateTime(2026, 1, 1),
        licenseUrl: 'https://res.cloudinary.com/test/license.pdf',
        licensePublicId: 'lic_pub_1',
        rmohCertUrl: 'https://res.cloudinary.com/test/rmoh.pdf',
        rmohCertPublicId: 'rmoh_pub_1',
        submittedAt: DateTime(2026, 1, 2),
        rejectionReason: 'Blurry document image',
        reviewedAt: DateTime(2026, 1, 3),
        reviewedBy: 'reviewer-jeferson',
      );

      // Calling copyWith with rejectionReason: null without flag should NOT clear it (backward compatible)
      final regularCopyWith = original.copyWith(name: 'Updated Name');
      expect(regularCopyWith.rejectionReason, 'Blurry document image');

      // Calling copyWith with clearRejectionReason: true explicitly clears rejectionReason
      final cleared = original.copyWith(
        clearRejectionReason: true,
      );

      expect(cleared.rejectionReason, isNull);
      // All other verification metadata MUST be preserved intact
      expect(cleared.licenseUrl, 'https://res.cloudinary.com/test/license.pdf');
      expect(cleared.licensePublicId, 'lic_pub_1');
      expect(cleared.rmohCertUrl, 'https://res.cloudinary.com/test/rmoh.pdf');
      expect(cleared.rmohCertPublicId, 'rmoh_pub_1');
      expect(cleared.submittedAt, DateTime(2026, 1, 2));
      expect(cleared.reviewedAt, DateTime(2026, 1, 3));
      expect(cleared.reviewedBy, 'reviewer-jeferson');
      expect(cleared.status, 'rejected');
    });

    test('supports explicit clearing of reviewedAt and reviewedBy', () {
      final original = PharmacyEntity(
        id: 'pharm-1',
        name: 'Test Pharmacy',
        area: 'Remera',
        phone: '+250788111222',
        email: 'test@pharmacy.rw',
        latitude: -1.95,
        longitude: 30.06,
        ownerId: 'owner-1',
        status: 'pending',
        createdAt: DateTime(2026, 1, 1),
        reviewedAt: DateTime(2026, 1, 3),
        reviewedBy: 'reviewer-jeferson',
      );

      final cleared = original.copyWith(
        clearReviewedAt: true,
        clearReviewedBy: true,
      );

      expect(cleared.reviewedAt, isNull);
      expect(cleared.reviewedBy, isNull);
    });

    test('correctly identifies rejected without resubmission vs resubmitted awaiting review', () {
      final rejectionTime = DateTime(2026, 1, 5, 14, 0);
      final initialSubmissionTime = DateTime(2026, 1, 4, 10, 0);

      final rejectedNoResubmission = PharmacyEntity(
        id: 'pharm-1',
        name: 'Test Pharmacy',
        area: 'Remera',
        phone: '+250788111222',
        email: 'test@pharmacy.rw',
        latitude: -1.95,
        longitude: 30.06,
        ownerId: 'owner-1',
        status: 'rejected',
        createdAt: DateTime(2026, 1, 1),
        submittedAt: initialSubmissionTime,
        reviewedAt: rejectionTime,
        rejectionReason: 'Invalid RMOH document',
      );

      expect(rejectedNoResubmission.isRejected, isTrue);
      expect(rejectedNoResubmission.isRejectedWithoutResubmission, isTrue);
      expect(rejectedNoResubmission.isResubmittedAwaitingReview, isFalse);
      expect(rejectedNoResubmission.isAwaitingReview, isFalse);

      // Now partner resubmits documents after rejection
      final resubmissionTime = DateTime(2026, 1, 6, 9, 30);
      final resubmittedPharmacy = rejectedNoResubmission.copyWith(
        submittedAt: resubmissionTime,
        // Status and reviewer fields remain unchanged because client cannot modify reviewer fields
      );

      expect(resubmittedPharmacy.isRejected, isTrue);
      expect(resubmittedPharmacy.isRejectedWithoutResubmission, isFalse);
      expect(resubmittedPharmacy.isResubmittedAwaitingReview, isTrue);
      expect(resubmittedPharmacy.isAwaitingReview, isTrue);

      // Reviewer rejects again with new review timestamp
      final secondRejectionTime = DateTime(2026, 1, 7, 11, 0);
      final secondRejection = resubmittedPharmacy.copyWith(
        reviewedAt: secondRejectionTime,
        rejectionReason: 'Still illegible',
      );

      expect(secondRejection.isRejected, isTrue);
      expect(secondRejection.isRejectedWithoutResubmission, isTrue);
      expect(secondRejection.isResubmittedAwaitingReview, isFalse);
      expect(secondRejection.isAwaitingReview, isFalse);
    });
  });

  group('PharmacyModel copyWith clearing support', () {
    test('clears rejectionReason when clearRejectionReason is true', () {
      final model = PharmacyModel(
        id: 'pharm-m1',
        name: 'Model Pharmacy',
        area: 'Kacyiru',
        district: 'Gasabo',
        phone: '+250788111222',
        email: 'model@pharmacy.rw',
        hours: '8-10',
        latitude: -1.95,
        longitude: 30.06,
        ownerId: 'owner-m1',
        status: 'rejected',
        createdAt: DateTime(2026, 1, 1),
        rejectionReason: 'Old reason',
        reviewedAt: DateTime(2026, 1, 2),
        reviewedBy: 'jeferson',
      );

      final cleared = model.copyWith(clearRejectionReason: true);
      expect(cleared.rejectionReason, isNull);
      expect(cleared.reviewedAt, DateTime(2026, 1, 2));
      expect(cleared.reviewedBy, 'jeferson');
      expect(cleared.status, 'rejected');
    });
  });
}

