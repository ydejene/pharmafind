import 'package:flutter_test/flutter_test.dart';
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
      expect(pharmacies.first.name, 'Green Health Pharmacy');
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
  });
}
