import 'package:flutter_test/flutter_test.dart';
import 'package:pharmafind/data/datasources/mock_pharmacy_datasource.dart';
import 'package:pharmafind/data/models/pharmacy_model.dart';
import 'package:pharmafind/data/models/stock_item_model.dart';

void main() {
  group('MockPharmacyDataSource', () {
    late MockPharmacyDataSource dataSource;

    setUp(() {
      dataSource = MockPharmacyDataSource();
    });

    test('initializes with seeded Kigali pharmacies and stock items', () async {
      final approved = await dataSource.getApprovedPharmacies();
      expect(approved.length, 4);
      expect(approved.any((p) => p.name == 'Green Health Pharmacy'), isTrue);

      final stock = await dataSource.getPharmacyStock('pharm-1');
      expect(stock.length, 2);
      expect(stock.any((s) => s.medicineName == 'Amoxicillin 500mg'), isTrue);
    });

    test(
      'can initialize with empty data when seedInitialData is false',
      () async {
        final emptyDataSource = MockPharmacyDataSource(seedInitialData: false);
        expect(await emptyDataSource.getApprovedPharmacies(), isEmpty);
        expect(await emptyDataSource.getPharmacyStock('pharm-1'), isEmpty);
      },
    );

    test(
      'getPharmacyByOwner returns correct pharmacy or null for unknown owner',
      () async {
        final pharmacy = await dataSource.getPharmacyByOwner('owner-1');
        expect(pharmacy, isNotNull);
        expect(pharmacy!.id, 'pharm-1');
        expect(pharmacy.name, 'Green Health Pharmacy');

        final unknown = await dataSource.getPharmacyByOwner(
          'non-existent-owner',
        );
        expect(unknown, isNull);
      },
    );

    test(
      'createPharmacy and updatePharmacy mutate data consistently',
      () async {
        final newPharmacy = PharmacyModel(
          id: '',
          name: 'Nyabugogo Pharmacy',
          area: 'Nyabugogo',
          district: 'Nyarugenge',
          phone: '+250 788 999 888',
          email: 'nyabugogo@pharma.rw',
          hours: '24/7',
          latitude: -1.9390,
          longitude: 29.8600,
          ownerId: 'owner-new',
          status: 'approved',
          acceptsInsurance: true,
          createdAt: DateTime.now(),
        );

        final generatedId = await dataSource.createPharmacy(newPharmacy);
        expect(generatedId, isNotEmpty);

        final fetched = await dataSource.getPharmacy(generatedId);
        expect(fetched, isNotNull);
        expect(fetched!.name, 'Nyabugogo Pharmacy');
        expect(fetched.ownerId, 'owner-new');

        final updated = fetched.copyWith(name: 'Nyabugogo Central Pharmacy');
        await dataSource.updatePharmacy(updated);

        final reFetched = await dataSource.getPharmacy(generatedId);
        expect(reFetched!.name, 'Nyabugogo Central Pharmacy');
      },
    );

    test(
      'deletePharmacy removes pharmacy and cascades to delete its stock items',
      () async {
        final stockBefore = await dataSource.getPharmacyStock('pharm-1');
        expect(stockBefore, isNotEmpty);

        await dataSource.deletePharmacy('pharm-1');

        final pharmacyAfter = await dataSource.getPharmacy('pharm-1');
        expect(pharmacyAfter, isNull);

        final stockAfter = await dataSource.getPharmacyStock('pharm-1');
        expect(stockAfter, isEmpty);
      },
    );

    test('searchMedicine returns matching non-out-of-stock items', () async {
      final results = await dataSource.searchMedicine('Amoxicillin');
      expect(results.length, 2);
      expect(results.every((item) => item.status != 'out_of_stock'), isTrue);

      final emptyResults = await dataSource.searchMedicine(
        'NonExistentMedicine',
      );
      expect(emptyResults, isEmpty);

      final emptyQueryResults = await dataSource.searchMedicine('   ');
      expect(emptyQueryResults, isEmpty);
    });

    test('stock CRUD operations maintain data consistency', () async {
      final newItem = StockItemModel(
        id: '',
        pharmacyId: 'pharm-1',
        pharmacyName: 'Green Health Pharmacy',
        pharmacyArea: 'Kimironko',
        pharmacyPhone: '+250 788 123 456',
        pharmacyHours: '7:00 AM - 9:00 PM',
        pharmacyLat: -1.9441,
        pharmacyLng: 29.8739,
        medicineName: 'Ciprofloxacin 500mg',
        status: 'in_stock',
        quantity: 30,
        price: 4500,
        updatedAt: DateTime.now(),
      );

      final stockId = await dataSource.addStockItem(newItem);
      expect(stockId, isNotEmpty);

      var stock = await dataSource.getPharmacyStock('pharm-1');
      expect(stock.any((s) => s.id == stockId), isTrue);

      final addedItem = stock.firstWhere((s) => s.id == stockId);
      final updatedItem = addedItem.copyWith(quantity: 25, price: 5000);
      await dataSource.updateStockItem(updatedItem);

      stock = await dataSource.getPharmacyStock('pharm-1');
      final fetchedUpdated = stock.firstWhere((s) => s.id == stockId);
      expect(fetchedUpdated.quantity, 25);
      expect(fetchedUpdated.price, 5000);

      await dataSource.deleteStockItem(stockId);
      stock = await dataSource.getPharmacyStock('pharm-1');
      expect(stock.any((s) => s.id == stockId), isFalse);
    });

    test(
      'watchPharmacyStock emits initial stock and updates on mutations',
      () async {
        final emissions = <List<StockItemModel>>[];
        final sub = dataSource
            .watchPharmacyStock('pharm-1')
            .listen(emissions.add);

        await Future.delayed(const Duration(milliseconds: 50));
        expect(emissions.length, 1);
        final initialCount = emissions.first.length;

        await dataSource.addStockItem(
          StockItemModel(
            id: 'watch-test-1',
            pharmacyId: 'pharm-1',
            pharmacyName: 'Green Health Pharmacy',
            medicineName: 'Vitamin C 1000mg',
            quantity: 50,
            price: 1500,
            updatedAt: DateTime.now(),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 50));
        expect(emissions.length, 2);
        expect(emissions.last.length, initialCount + 1);

        await sub.cancel();
      },
    );
  });
}
