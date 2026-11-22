import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pharmafind/data/datasources/mock_cloudinary_datasource.dart';
import 'package:pharmafind/data/datasources/mock_pharmacy_datasource.dart';
import 'package:pharmafind/data/repositories/pharmacy_repository_impl.dart';
import 'package:pharmafind/domain/entities/pharmacy_entity.dart';
import 'package:pharmafind/domain/entities/stock_item_entity.dart';

void main() {
  group('PharmacyRepositoryImpl', () {
    late MockPharmacyDataSource dataSource;
    late PharmacyRepositoryImpl repository;

    setUp(() {
      dataSource = MockPharmacyDataSource();
      repository = PharmacyRepositoryImpl(datasource: dataSource);
    });

    test('getApprovedPharmacies delegates to datasource and returns mapped entities', () async {
      final pharmacies = await repository.getApprovedPharmacies();
      expect(pharmacies, isNotEmpty);
      expect(pharmacies.first, isA<PharmacyEntity>());
      expect(pharmacies.first.name, 'Teta Pharmacy');
    });

    test('getPharmacyByOwner maps model to entity or returns null', () async {
      final pharmacy = await repository.getPharmacyByOwner('owner-1');
      expect(pharmacy, isNotNull);
      expect(pharmacy, isA<PharmacyEntity>());
      expect(pharmacy!.id, 'pharm-1');

      final notFound = await repository.getPharmacyByOwner('non-existent');
      expect(notFound, isNull);
    });

    test(
      'createPharmacy and updatePharmacy map entity to model correctly',
      () async {
        final newEntity = PharmacyEntity(
          id: '',
          name: 'Gikondo Pharmacy',
          area: 'Gikondo',
          district: 'Kicukiro',
          phone: '+250 788 777 666',
          email: 'gikondo@pharma.rw',
          hours: '8:00 AM - 8:00 PM',
          latitude: -1.9600,
          longitude: 29.8700,
          ownerId: 'owner-gikondo',
          status: 'approved',
          acceptsInsurance: true,
          createdAt: DateTime.now(),
        );

        final id = await repository.createPharmacy(newEntity);
        expect(id, isNotEmpty);

        final fetched = await repository.getPharmacy(id);
        expect(fetched, isNotNull);
        expect(fetched!.name, 'Gikondo Pharmacy');
        expect(fetched.ownerId, 'owner-gikondo');

        final updatedEntity = PharmacyEntity(
          id: id,
          name: 'Gikondo Express Pharmacy',
          area: fetched.area,
          district: fetched.district,
          phone: fetched.phone,
          email: fetched.email,
          hours: fetched.hours,
          latitude: fetched.latitude,
          longitude: fetched.longitude,
          ownerId: fetched.ownerId,
          status: fetched.status,
          acceptsInsurance: fetched.acceptsInsurance,
          createdAt: fetched.createdAt,
        );

        await repository.updatePharmacy(updatedEntity);
        final reFetched = await repository.getPharmacy(id);
        expect(reFetched!.name, 'Gikondo Express Pharmacy');
      },
    );

    test('deletePharmacy delegates deletion to datasource', () async {
      await repository.deletePharmacy('pharm-1');
      final fetched = await repository.getPharmacy('pharm-1');
      expect(fetched, isNull);
    });

    test('searchMedicine returns StockItemEntity list', () async {
      final results = await repository.searchMedicine('Amoxicillin');
      expect(results, isNotEmpty);
      expect(results.first, isA<StockItemEntity>());
      expect(results.first.medicineName, contains('Amoxicillin'));
    });

    test(
      'stock CRUD operations map bidirectionally and delegate to datasource',
      () async {
        final item = StockItemEntity(
          id: '',
          pharmacyId: 'pharm-2',
          pharmacyName: 'Kigali Pharma Plus',
          pharmacyArea: 'Nyarutarama',
          pharmacyPhone: '+250 788 654 321',
          pharmacyHours: '8:00 AM - 10:00 PM',
          pharmacyLat: -1.9380,
          pharmacyLng: 29.8800,
          medicineName: 'Azithromycin 500mg',
          status: 'in_stock',
          quantity: 20,
          price: 7500,
          updatedAt: DateTime.now(),
        );

        final id = await repository.addStockItem(item);
        expect(id, isNotEmpty);

        var stock = await repository.getPharmacyStock('pharm-2');
        expect(stock.any((s) => s.id == id), isTrue);

        final added = stock.firstWhere((s) => s.id == id);
        final updated = StockItemEntity(
          id: added.id,
          pharmacyId: added.pharmacyId,
          pharmacyName: added.pharmacyName,
          pharmacyArea: added.pharmacyArea,
          pharmacyPhone: added.pharmacyPhone,
          pharmacyHours: added.pharmacyHours,
          pharmacyLat: added.pharmacyLat,
          pharmacyLng: added.pharmacyLng,
          medicineName: added.medicineName,
          status: added.status,
          quantity: 15,
          price: 8000,
          updatedAt: added.updatedAt,
        );

        await repository.updateStockItem(updated);
        stock = await repository.getPharmacyStock('pharm-2');
        final fetchedUpdated = stock.firstWhere((s) => s.id == id);
        expect(fetchedUpdated.quantity, 15);
        expect(fetchedUpdated.price, 8000);

        await repository.deleteStockItem(id);
        stock = await repository.getPharmacyStock('pharm-2');
        expect(stock.any((s) => s.id == id), isFalse);
      },
    );

    test('watchPharmacyStock maps stream models to domain entities', () async {
      final stream = repository.watchPharmacyStock('pharm-1');
      final firstEmission = await stream.first;
      expect(firstEmission, isNotEmpty);
      expect(firstEmission.first, isA<StockItemEntity>());
    });

    test('submitVerificationDocuments uploads both files and updates pharmacy', () async {
      final mockCloudinary = MockCloudinaryDataSource();
      final customRepo = PharmacyRepositoryImpl(
        datasource: dataSource,
        cloudinaryDatasource: mockCloudinary,
      );

      final licenseBytes = Uint8List.fromList([1, 2, 3]);
      final rmohBytes = Uint8List.fromList([4, 5, 6]);

      final updated = await customRepo.submitVerificationDocuments(
        pharmacyId: 'pharm-1',
        licenseBytes: licenseBytes,
        licenseFilename: 'license.pdf',
        rmohBytes: rmohBytes,
        rmohFilename: 'rmoh.pdf',
      );

      expect(updated.licenseUrl, contains('license.pdf'));
      expect(updated.licensePublicId, contains('license.pdf'));
      expect(updated.rmohCertUrl, contains('rmoh.pdf'));
      expect(updated.rmohCertPublicId, contains('rmoh.pdf'));
      expect(updated.submittedAt, isNotNull);

      final persisted = await dataSource.getPharmacy('pharm-1');
      expect(persisted?.licenseUrl, contains('license.pdf'));
      expect(persisted?.submittedAt, isNotNull);
    });

    test('submitVerificationDocuments throws when pharmacy does not exist', () async {
      expect(
        () => repository.submitVerificationDocuments(
          pharmacyId: 'non-existent',
          licenseBytes: Uint8List(0),
          licenseFilename: 'a.pdf',
          rmohBytes: Uint8List(0),
          rmohFilename: 'b.pdf',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('submitVerificationDocuments replaces only license and preserves RMOH', () async {
      final mockCloudinary = MockCloudinaryDataSource();
      final customRepo = PharmacyRepositoryImpl(
        datasource: dataSource,
        cloudinaryDatasource: mockCloudinary,
      );

      // Pre-seed pharmacy with existing documents and rejection metadata
      final existing = await dataSource.getPharmacy('pharm-1');
      await dataSource.updatePharmacy(
        existing!.copyWith(
          licenseUrl: 'https://res.cloudinary.com/test/old_license.pdf',
          licensePublicId: 'old_license_id',
          rmohCertUrl: 'https://res.cloudinary.com/test/old_rmoh.pdf',
          rmohCertPublicId: 'old_rmoh_id',
          status: 'rejected',
          rejectionReason: 'Blurry license document',
          reviewedAt: DateTime(2026, 1, 10),
          reviewedBy: 'reviewer-jeferson',
        ),
      );

      final updated = await customRepo.submitVerificationDocuments(
        pharmacyId: 'pharm-1',
        licenseBytes: Uint8List.fromList([10, 20]),
        licenseFilename: 'clean_license.pdf',
      );

      expect(updated.licenseUrl, contains('clean_license.pdf'));
      expect(updated.licensePublicId, contains('clean_license.pdf'));
      // RMOH preserved
      expect(updated.rmohCertUrl, 'https://res.cloudinary.com/test/old_rmoh.pdf');
      expect(updated.rmohCertPublicId, 'old_rmoh_id');
      // Reviewer fields preserved
      expect(updated.status, 'rejected');
      expect(updated.rejectionReason, 'Blurry license document');
      expect(updated.reviewedAt, DateTime(2026, 1, 10));
      expect(updated.reviewedBy, 'reviewer-jeferson');
      // Submitted at updated to after review
      expect(updated.submittedAt, isNotNull);
      expect(updated.submittedAt!.isAfter(updated.reviewedAt!), isTrue);
      expect(updated.isResubmittedAwaitingReview, isTrue);
    });

    test('submitVerificationDocuments replaces only RMOH and preserves license', () async {
      final mockCloudinary = MockCloudinaryDataSource();
      final customRepo = PharmacyRepositoryImpl(
        datasource: dataSource,
        cloudinaryDatasource: mockCloudinary,
      );

      final existing = await dataSource.getPharmacy('pharm-1');
      await dataSource.updatePharmacy(
        existing!.copyWith(
          licenseUrl: 'https://res.cloudinary.com/test/valid_license.pdf',
          licensePublicId: 'valid_license_id',
          rmohCertUrl: 'https://res.cloudinary.com/test/expired_rmoh.pdf',
          rmohCertPublicId: 'expired_rmoh_id',
          status: 'rejected',
          rejectionReason: 'RMOH certificate expired',
          reviewedAt: DateTime(2026, 1, 10),
          reviewedBy: 'reviewer-jeferson',
        ),
      );

      final updated = await customRepo.submitVerificationDocuments(
        pharmacyId: 'pharm-1',
        rmohBytes: Uint8List.fromList([30, 40]),
        rmohFilename: 'renewed_rmoh.pdf',
      );

      // License preserved
      expect(updated.licenseUrl, 'https://res.cloudinary.com/test/valid_license.pdf');
      expect(updated.licensePublicId, 'valid_license_id');
      // RMOH updated
      expect(updated.rmohCertUrl, contains('renewed_rmoh.pdf'));
      expect(updated.rmohCertPublicId, contains('renewed_rmoh.pdf'));
      // Reviewer fields protected
      expect(updated.status, 'rejected');
      expect(updated.rejectionReason, 'RMOH certificate expired');
      expect(updated.isResubmittedAwaitingReview, isTrue);
    });

    test('submitVerificationDocuments throws ArgumentError on initial submission when only license is provided', () async {
      final mockCloudinary = MockCloudinaryDataSource();
      final customRepo = PharmacyRepositoryImpl(
        datasource: dataSource,
        cloudinaryDatasource: mockCloudinary,
      );

      // Reset pharm-1 so it has NO documents
      final existing = await dataSource.getPharmacy('pharm-1');
      await dataSource.updatePharmacy(
        existing!.copyWith(
          licenseUrl: null,
          licensePublicId: null,
          rmohCertUrl: null,
          rmohCertPublicId: null,
          submittedAt: null,
        ),
      );

      await expectLater(
        () => customRepo.submitVerificationDocuments(
          pharmacyId: 'pharm-1',
          licenseBytes: Uint8List.fromList([1, 2]),
          licenseFilename: 'license.pdf',
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Verify no mutation occurred on datasource
      final check = await dataSource.getPharmacy('pharm-1');
      expect(check?.submittedAt, isNull);
      expect(check?.licenseUrl, isNull);
    });

    test('submitVerificationDocuments throws ArgumentError on initial submission when only RMOH is provided', () async {
      final mockCloudinary = MockCloudinaryDataSource();
      final customRepo = PharmacyRepositoryImpl(
        datasource: dataSource,
        cloudinaryDatasource: mockCloudinary,
      );

      final existing = await dataSource.getPharmacy('pharm-1');
      await dataSource.updatePharmacy(
        existing!.copyWith(
          licenseUrl: null,
          licensePublicId: null,
          rmohCertUrl: null,
          rmohCertPublicId: null,
          submittedAt: null,
        ),
      );

      await expectLater(
        () => customRepo.submitVerificationDocuments(
          pharmacyId: 'pharm-1',
          rmohBytes: Uint8List.fromList([3, 4]),
          rmohFilename: 'rmoh.pdf',
        ),
        throwsA(isA<ArgumentError>()),
      );

      final check = await dataSource.getPharmacy('pharm-1');
      expect(check?.submittedAt, isNull);
      expect(check?.rmohCertUrl, isNull);
    });

    test('persists server timestamp and reads it back mapped to PharmacyEntity', () async {
      final mockCloudinary = MockCloudinaryDataSource();
      final customRepo = PharmacyRepositoryImpl(
        datasource: dataSource,
        cloudinaryDatasource: mockCloudinary,
      );

      // Simulate past review decision
      final reviewTime = DateTime.now().subtract(const Duration(minutes: 5));

      final existing = await dataSource.getPharmacy('pharm-1');
      await dataSource.updatePharmacy(
        existing!.copyWith(
          licenseUrl: 'https://res.cloudinary.com/test/valid_license.pdf',
          licensePublicId: 'valid_license_id',
          rmohCertUrl: 'https://res.cloudinary.com/test/expired_rmoh.pdf',
          rmohCertPublicId: 'expired_rmoh_id',
          status: 'rejected',
          rejectionReason: 'RMOH certificate expired',
          reviewedAt: reviewTime,
          reviewedBy: 'reviewer-jeferson',
        ),
      );

      final updated = await customRepo.submitVerificationDocuments(
        pharmacyId: 'pharm-1',
        rmohBytes: Uint8List.fromList([30, 40]),
        rmohFilename: 'renewed_rmoh.pdf',
      );

      // submittedAt is read back from the datasource and is after reviewedAt
      expect(updated.submittedAt, isNotNull);
      expect(updated.submittedAt!.isAfter(updated.reviewedAt!), isTrue);
      expect(updated.isResubmittedAwaitingReview, isTrue);

      final persisted = await dataSource.getPharmacy('pharm-1');
      expect(persisted?.submittedAt, updated.submittedAt);
    });

    test('submitVerificationDocuments throws ArgumentError when no files provided', () async {
      expect(
        () => repository.submitVerificationDocuments(
          pharmacyId: 'pharm-1',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('upload failure does not mutate persisted pharmacy documents', () async {
      final failingCloudinary = MockCloudinaryDataSource()..shouldThrow = true;
      final customRepo = PharmacyRepositoryImpl(
        datasource: dataSource,
        cloudinaryDatasource: failingCloudinary,
      );

      final existing = await dataSource.getPharmacy('pharm-1');
      await dataSource.updatePharmacy(
        existing!.copyWith(
          licenseUrl: 'https://res.cloudinary.com/test/original_license.pdf',
          rmohCertUrl: 'https://res.cloudinary.com/test/original_rmoh.pdf',
          status: 'rejected',
          rejectionReason: 'Original rejection',
        ),
      );

      await expectLater(
        () => customRepo.submitVerificationDocuments(
          pharmacyId: 'pharm-1',
          licenseBytes: Uint8List.fromList([1, 2]),
          licenseFilename: 'new_license.pdf',
        ),
        throwsA(isA<Exception>()),
      );

      final persisted = await dataSource.getPharmacy('pharm-1');
      expect(persisted?.licenseUrl, 'https://res.cloudinary.com/test/original_license.pdf');
      expect(persisted?.status, 'rejected');
      expect(persisted?.rejectionReason, 'Original rejection');
    });
  });
}
