import 'package:flutter_test/flutter_test.dart';
import 'package:pharmafind/domain/entities/pharmacy_entity.dart';
import 'package:pharmafind/domain/entities/stock_item_entity.dart';
import 'package:pharmafind/domain/repositories/pharmacy_repository.dart';
import 'package:pharmafind/domain/usecases/pharmacy/add_stock_item_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/create_pharmacy_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/delete_stock_item_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/get_pharmacy_by_owner_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/get_pharmacy_stock_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/update_pharmacy_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/update_stock_item_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/watch_pharmacy_stock_usecase.dart';

class _FakePharmacyRepository implements IPharmacyRepository {
  PharmacyEntity? pharmacyToReturn;
  List<StockItemEntity> stockToReturn = [];
  String createdPharmacyId = 'created-pharm-id';
  String createdStockId = 'created-stock-id';

  PharmacyEntity? lastCreatedPharmacy;
  PharmacyEntity? lastUpdatedPharmacy;
  StockItemEntity? lastCreatedStock;
  StockItemEntity? lastUpdatedStock;
  String? lastDeletedStockId;
  String? lastQueriedOwnerId;
  String? lastQueriedPharmacyId;
  String? lastWatchedPharmacyId;
  Stream<List<StockItemEntity>>? streamToReturn;

  @override
  Future<PharmacyEntity?> getPharmacyByOwner(String ownerId) async {
    lastQueriedOwnerId = ownerId;
    return pharmacyToReturn;
  }

  @override
  Future<String> createPharmacy(PharmacyEntity pharmacy) async {
    lastCreatedPharmacy = pharmacy;
    return createdPharmacyId;
  }

  @override
  Future<void> updatePharmacy(PharmacyEntity pharmacy) async {
    lastUpdatedPharmacy = pharmacy;
  }

  @override
  Future<List<StockItemEntity>> getPharmacyStock(String pharmacyId) async {
    lastQueriedPharmacyId = pharmacyId;
    return stockToReturn;
  }

  @override
  Future<String> addStockItem(StockItemEntity item) async {
    lastCreatedStock = item;
    return createdStockId;
  }

  @override
  Future<void> updateStockItem(StockItemEntity item) async {
    lastUpdatedStock = item;
  }

  @override
  Future<void> deleteStockItem(String stockId) async {
    lastDeletedStockId = stockId;
  }

  @override
  Future<void> deletePharmacy(String pharmacyId) async {}

  @override
  Future<PharmacyEntity?> getPharmacy(String pharmacyId) async => null;

  @override
  Future<List<PharmacyEntity>> getApprovedPharmacies() async => [];

  @override
  Future<List<StockItemEntity>> searchMedicine(String query) async => [];

  @override
  Stream<List<StockItemEntity>> watchPharmacyStock(String pharmacyId) {
    lastWatchedPharmacyId = pharmacyId;
    return streamToReturn ?? Stream.value(stockToReturn);
  }
}

void main() {
  group('Pharmacy Domain Use Cases', () {
    late _FakePharmacyRepository fakeRepo;

    final testPharmacy = PharmacyEntity(
      id: 'pharm-test',
      name: 'Test Pharmacy',
      area: 'Kicukiro',
      district: 'Kicukiro',
      phone: '+250 788 000 111',
      email: 'test@pharma.rw',
      hours: '8:00 AM - 8:00 PM',
      latitude: -1.95,
      longitude: 29.87,
      ownerId: 'owner-test',
      status: 'approved',
      acceptsInsurance: true,
      createdAt: DateTime(2025, 1, 1),
    );

    final testStock = StockItemEntity(
      id: 'stock-test',
      pharmacyId: 'pharm-test',
      pharmacyName: 'Test Pharmacy',
      pharmacyArea: 'Kicukiro',
      pharmacyPhone: '+250 788 000 111',
      pharmacyHours: '8:00 AM - 8:00 PM',
      pharmacyLat: -1.95,
      pharmacyLng: 29.87,
      medicineName: 'Amoxicillin',
      status: 'in_stock',
      quantity: 10,
      price: 3000,
      updatedAt: DateTime(2025, 1, 1),
    );

    setUp(() {
      fakeRepo = _FakePharmacyRepository();
    });

    test(
      'GetPharmacyByOwnerUseCase delegates correctly to repository',
      () async {
        fakeRepo.pharmacyToReturn = testPharmacy;
        final useCase = GetPharmacyByOwnerUseCase(fakeRepo);

        final result = await useCase('owner-test');
        expect(result, equals(testPharmacy));
        expect(fakeRepo.lastQueriedOwnerId, 'owner-test');
      },
    );

    test(
      'CreatePharmacyUseCase delegates pharmacy creation and returns id',
      () async {
        final useCase = CreatePharmacyUseCase(fakeRepo);

        final result = await useCase(testPharmacy);
        expect(result, 'created-pharm-id');
        expect(fakeRepo.lastCreatedPharmacy, equals(testPharmacy));
      },
    );

    test('UpdatePharmacyUseCase delegates update to repository', () async {
      final useCase = UpdatePharmacyUseCase(fakeRepo);

      await useCase(testPharmacy);
      expect(fakeRepo.lastUpdatedPharmacy, equals(testPharmacy));
    });

    test(
      'GetPharmacyStockUseCase delegates stock query to repository',
      () async {
        fakeRepo.stockToReturn = [testStock];
        final useCase = GetPharmacyStockUseCase(fakeRepo);

        final result = await useCase('pharm-test');
        expect(result, equals([testStock]));
        expect(fakeRepo.lastQueriedPharmacyId, 'pharm-test');
      },
    );

    test(
      'AddStockItemUseCase delegates stock creation and returns generated id',
      () async {
        final useCase = AddStockItemUseCase(fakeRepo);

        final result = await useCase(testStock);
        expect(result, 'created-stock-id');
        expect(fakeRepo.lastCreatedStock, equals(testStock));
      },
    );

    test(
      'UpdateStockItemUseCase delegates stock update to repository',
      () async {
        final useCase = UpdateStockItemUseCase(fakeRepo);

        await useCase(testStock);
        expect(fakeRepo.lastUpdatedStock, equals(testStock));
      },
    );

    test(
      'DeleteStockItemUseCase delegates stock deletion to repository',
      () async {
        final useCase = DeleteStockItemUseCase(fakeRepo);

        await useCase('stock-test-id');
        expect(fakeRepo.lastDeletedStockId, 'stock-test-id');
      },
    );

    test(
      'WatchPharmacyStockUseCase delegates stream subscription to repository',
      () async {
        final useCase = WatchPharmacyStockUseCase(fakeRepo);
        fakeRepo.stockToReturn = [testStock];

        final stream = useCase('pharm-test');
        final emitted = await stream.first;

        expect(fakeRepo.lastWatchedPharmacyId, 'pharm-test');
        expect(emitted, [testStock]);
      },
    );
  });
}
