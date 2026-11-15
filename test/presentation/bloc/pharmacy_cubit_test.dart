import 'dart:async';

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
import 'package:pharmafind/presentation/bloc/pharmacy/pharmacy_cubit.dart';

class _MockPharmacyRepository implements IPharmacyRepository {
  PharmacyEntity? pharmacyByOwnerResult;
  Exception? pharmacyByOwnerError;

  String createdPharmacyId = 'assigned-pharm-123';
  Exception? createPharmacyError;
  PharmacyEntity? lastCreatedPharmacy;

  Exception? updatePharmacyError;
  PharmacyEntity? lastUpdatedPharmacy;

  List<StockItemEntity> stockResult = [];
  Exception? stockError;

  String createdStockId = 'assigned-stock-456';
  Exception? addStockError;
  StockItemEntity? lastAddedStock;

  Exception? updateStockError;
  StockItemEntity? lastUpdatedStock;

  Exception? deleteStockError;
  String? lastDeletedStockId;

  StreamController<List<StockItemEntity>>? streamController;
  int watchCallCount = 0;
  String? lastWatchedPharmacyId;

  @override
  Future<PharmacyEntity?> getPharmacyByOwner(String ownerId) async {
    if (pharmacyByOwnerError != null) throw pharmacyByOwnerError!;
    return pharmacyByOwnerResult;
  }

  @override
  Future<String> createPharmacy(PharmacyEntity pharmacy) async {
    if (createPharmacyError != null) throw createPharmacyError!;
    lastCreatedPharmacy = pharmacy;
    return createdPharmacyId;
  }

  @override
  Future<void> updatePharmacy(PharmacyEntity pharmacy) async {
    if (updatePharmacyError != null) throw updatePharmacyError!;
    lastUpdatedPharmacy = pharmacy;
  }

  @override
  Future<List<StockItemEntity>> getPharmacyStock(String pharmacyId) async {
    if (stockError != null) throw stockError!;
    return stockResult;
  }

  @override
  Future<String> addStockItem(StockItemEntity item) async {
    if (addStockError != null) throw addStockError!;
    lastAddedStock = item;
    return createdStockId;
  }

  @override
  Future<void> updateStockItem(StockItemEntity item) async {
    if (updateStockError != null) throw updateStockError!;
    lastUpdatedStock = item;
  }

  @override
  Future<void> deleteStockItem(String stockId) async {
    if (deleteStockError != null) throw deleteStockError!;
    lastDeletedStockId = stockId;
  }

  @override
  Stream<List<StockItemEntity>> watchPharmacyStock(String pharmacyId) {
    watchCallCount++;
    lastWatchedPharmacyId = pharmacyId;
    return streamController?.stream ?? Stream.value(stockResult);
  }

  @override
  Future<void> deletePharmacy(String pharmacyId) async {}

  @override
  Future<PharmacyEntity?> getPharmacy(String pharmacyId) async => null;

  @override
  Future<List<PharmacyEntity>> getApprovedPharmacies() async => [];

  @override
  Future<List<StockItemEntity>> searchMedicine(String query) async => [];
}

void main() {
  group('PharmacyCubit State Management Tests', () {
    late _MockPharmacyRepository repo;
    late PharmacyCubit cubit;

    final testPharmacy = PharmacyEntity(
      id: 'pharm-1',
      name: 'City Care Pharmacy',
      area: 'Kacyiru',
      district: 'Gasabo',
      phone: '+250 788 111 222',
      email: 'citycare@pharmacy.rw',
      hours: '8:00 AM - 10:00 PM',
      latitude: -1.944,
      longitude: 30.061,
      ownerId: 'partner-user-123',
      status: 'approved',
      acceptsInsurance: true,
      createdAt: DateTime(2025, 1, 1),
    );

    final testStock = StockItemEntity(
      id: 'stock-1',
      pharmacyId: 'pharm-1',
      pharmacyName: 'City Care Pharmacy',
      pharmacyArea: 'Kacyiru',
      pharmacyPhone: '+250 788 111 222',
      pharmacyHours: '8:00 AM - 10:00 PM',
      pharmacyLat: -1.944,
      pharmacyLng: 30.061,
      medicineName: 'Paracetamol 500mg',
      status: 'in_stock',
      quantity: 100,
      price: 1500,
      updatedAt: DateTime(2025, 1, 2),
    );

    setUp(() {
      repo = _MockPharmacyRepository();
      cubit = PharmacyCubit(
        getPharmacyByOwnerUseCase: GetPharmacyByOwnerUseCase(repo),
        getPharmacyStockUseCase: GetPharmacyStockUseCase(repo),
        createPharmacyUseCase: CreatePharmacyUseCase(repo),
        updatePharmacyUseCase: UpdatePharmacyUseCase(repo),
        addStockItemUseCase: AddStockItemUseCase(repo),
        updateStockItemUseCase: UpdateStockItemUseCase(repo),
        deleteStockItemUseCase: DeleteStockItemUseCase(repo),
        watchPharmacyStockUseCase: WatchPharmacyStockUseCase(repo),
      );
    });

    tearDown(() async {
      await cubit.close();
      await repo.streamController?.close();
    });

    test('Initial state is correct', () {
      expect(cubit.state.status, PharmacyStatus.initial);
      expect(cubit.state.pharmacy, isNull);
      expect(cubit.state.stockItems, isEmpty);
      expect(cubit.state.errorMessage, isNull);
    });

    group('loadPharmacy', () {
      test(
        'emits [loading, loaded] and subscribes when pharmacy exists',
        () async {
          repo.pharmacyByOwnerResult = testPharmacy;
          repo.stockResult = [testStock];

          final states = <PharmacyState>[];
          final sub = cubit.stream.listen(states.add);

          await cubit.loadPharmacy('partner-user-123');
          await pumpEventQueue();
          await sub.cancel();

          expect(states.length, 2);
          expect(states[0].status, PharmacyStatus.loading);
          expect(states[1].status, PharmacyStatus.loaded);
          expect(states[1].pharmacy, equals(testPharmacy));
          expect(states[1].stockItems, equals([testStock]));
          expect(repo.watchCallCount, 1);
          expect(repo.lastWatchedPharmacyId, 'pharm-1');
        },
      );

      test('emits [loading, noPharmacy] when no pharmacy found', () async {
        repo.pharmacyByOwnerResult = null;

        final states = <PharmacyState>[];
        final sub = cubit.stream.listen(states.add);

        await cubit.loadPharmacy('unknown-owner');
        await pumpEventQueue();
        await sub.cancel();

        expect(states.length, 2);
        expect(states[0].status, PharmacyStatus.loading);
        expect(states[1].status, PharmacyStatus.noPharmacy);
        expect(states[1].pharmacy, isNull);
        expect(states[1].stockItems, isEmpty);
      });

      test('emits [loading, error] when repository throws error', () async {
        repo.pharmacyByOwnerError = Exception('Network error');

        final states = <PharmacyState>[];
        final sub = cubit.stream.listen(states.add);

        await cubit.loadPharmacy('partner-user-123');
        await pumpEventQueue();
        await sub.cancel();

        expect(states.length, 2);
        expect(states[0].status, PharmacyStatus.loading);
        expect(states[1].status, PharmacyStatus.error);
        expect(states[1].errorMessage, contains('Network error'));
      });
    });

    group('createPharmacy', () {
      test(
        'emits [loading, loaded] with assigned id and preserves ownerId',
        () async {
          final newPharmacy = PharmacyEntity(
            id: '',
            name: 'New Pharmacy',
            area: 'Remera',
            district: 'Gasabo',
            phone: '+250 788 333 444',
            email: 'new@pharma.rw',
            latitude: -1.96,
            longitude: 30.11,
            ownerId: 'partner-user-123',
            status: 'pending',
            acceptsInsurance: true,
            createdAt: DateTime(2025, 2, 1),
          );

          repo.createdPharmacyId = 'assigned-pharm-999';

          final states = <PharmacyState>[];
          final sub = cubit.stream.listen(states.add);

          await cubit.createPharmacy(newPharmacy);
          await pumpEventQueue();
          await sub.cancel();

          expect(states.length, 2);
          expect(states[0].status, PharmacyStatus.loading);
          expect(states[1].status, PharmacyStatus.loaded);
          expect(states[1].pharmacy?.id, 'assigned-pharm-999');
          expect(states[1].pharmacy?.ownerId, 'partner-user-123');
          expect(repo.lastCreatedPharmacy?.ownerId, 'partner-user-123');
          expect(repo.watchCallCount, 1);
        },
      );

      test('emits [loading, error] on creation failure', () async {
        repo.createPharmacyError = Exception('Failed to create pharmacy');

        final states = <PharmacyState>[];
        final sub = cubit.stream.listen(states.add);

        await cubit.createPharmacy(testPharmacy);
        await pumpEventQueue();
        await sub.cancel();

        expect(states.length, 2);
        expect(states[0].status, PharmacyStatus.loading);
        expect(states[1].status, PharmacyStatus.error);
        expect(states[1].errorMessage, contains('Failed to create pharmacy'));
      });
    });

    group('updatePharmacy', () {
      test('emits loaded state with updated pharmacy entity', () async {
        final updated = PharmacyEntity(
          id: testPharmacy.id,
          name: 'Updated Care Pharmacy',
          area: 'Kacyiru',
          district: 'Gasabo',
          phone: '+250 788 999 888',
          email: testPharmacy.email,
          hours: '7:00 AM - 11:00 PM',
          latitude: testPharmacy.latitude,
          longitude: testPharmacy.longitude,
          ownerId: testPharmacy.ownerId,
          status: 'approved',
          acceptsInsurance: true,
          createdAt: testPharmacy.createdAt,
        );

        await cubit.updatePharmacy(updated);

        expect(cubit.state.status, PharmacyStatus.loaded);
        expect(cubit.state.pharmacy?.name, 'Updated Care Pharmacy');
        expect(cubit.state.pharmacy?.phone, '+250 788 999 888');
        expect(repo.lastUpdatedPharmacy, equals(updated));
      });

      test('emits error state when update fails', () async {
        repo.updatePharmacyError = Exception('Update permission denied');

        await cubit.updatePharmacy(testPharmacy);

        expect(cubit.state.status, PharmacyStatus.error);
        expect(cubit.state.errorMessage, contains('permission denied'));
      });
    });

    group('Stock Operations (load, add, update, delete, refresh)', () {
      test('loadStock fetches stock and emits loaded state', () async {
        repo.stockResult = [testStock];

        await cubit.loadStock('pharm-1');

        expect(cubit.state.status, PharmacyStatus.loaded);
        expect(cubit.state.stockItems, [testStock]);
      });

      test('refreshStock calls loadStock when pharmacy is present', () async {
        repo.pharmacyByOwnerResult = testPharmacy;
        repo.stockResult = [testStock];
        await cubit.loadPharmacy('partner-user-123');

        final newStock = StockItemEntity(
          id: 'stock-2',
          pharmacyId: 'pharm-1',
          pharmacyName: 'City Care Pharmacy',
          pharmacyArea: 'Kacyiru',
          pharmacyPhone: '+250 788 111 222',
          pharmacyHours: '8:00 AM - 10:00 PM',
          pharmacyLat: -1.944,
          pharmacyLng: 30.061,
          medicineName: 'Amoxicillin 500mg',
          status: 'low_stock',
          quantity: 5,
          price: 3500,
          updatedAt: DateTime(2025, 1, 3),
        );
        repo.stockResult = [testStock, newStock];

        await cubit.refreshStock();

        expect(cubit.state.stockItems.length, 2);
        expect(cubit.state.stockItems, contains(newStock));
      });

      test(
        'addStockItem adds item to state and delegates to usecase',
        () async {
          repo.createdStockId = 'assigned-stock-999';

          final itemToAdd = StockItemEntity(
            id: '',
            pharmacyId: 'pharm-1',
            pharmacyName: 'City Care Pharmacy',
            pharmacyArea: 'Kacyiru',
            pharmacyPhone: '+250 788 111 222',
            pharmacyHours: '8:00 AM - 10:00 PM',
            pharmacyLat: -1.944,
            pharmacyLng: 30.061,
            medicineName: 'Ibuprofen 400mg',
            status: 'in_stock',
            quantity: 50,
            price: 2000,
            updatedAt: DateTime(2025, 1, 4),
          );

          await cubit.addStockItem(itemToAdd);

          expect(cubit.state.status, PharmacyStatus.loaded);
          expect(cubit.state.stockItems.length, 1);
          expect(cubit.state.stockItems.first.id, 'assigned-stock-999');
          expect(repo.lastAddedStock, equals(itemToAdd));
        },
      );

      test('updateStockItem updates existing item in stock list', () async {
        repo.stockResult = [testStock];
        await cubit.loadStock('pharm-1');

        final updatedItem = StockItemEntity(
          id: testStock.id,
          pharmacyId: testStock.pharmacyId,
          pharmacyName: testStock.pharmacyName,
          pharmacyArea: testStock.pharmacyArea,
          pharmacyPhone: testStock.pharmacyPhone,
          pharmacyHours: testStock.pharmacyHours,
          pharmacyLat: testStock.pharmacyLat,
          pharmacyLng: testStock.pharmacyLng,
          medicineName: testStock.medicineName,
          status: 'low_stock',
          quantity: 8,
          price: 1800,
          updatedAt: DateTime(2025, 1, 5),
        );

        await cubit.updateStockItem(updatedItem);

        expect(cubit.state.status, PharmacyStatus.loaded);
        expect(cubit.state.stockItems.length, 1);
        expect(cubit.state.stockItems.first.quantity, 8);
        expect(cubit.state.stockItems.first.price, 1800);
        expect(repo.lastUpdatedStock, equals(updatedItem));
      });

      test('deleteStockItem removes item from state list', () async {
        repo.stockResult = [testStock];
        await cubit.loadStock('pharm-1');

        await cubit.deleteStockItem(testStock.id);

        expect(cubit.state.status, PharmacyStatus.loaded);
        expect(cubit.state.stockItems, isEmpty);
        expect(repo.lastDeletedStockId, testStock.id);
      });

      test('CRUD operations emit error state when usecase throws', () async {
        repo.addStockError = Exception('Add failed');
        await cubit.addStockItem(testStock);
        expect(cubit.state.status, PharmacyStatus.error);
        expect(cubit.state.errorMessage, contains('Add failed'));

        repo.updateStockError = Exception('Update failed');
        await cubit.updateStockItem(testStock);
        expect(cubit.state.status, PharmacyStatus.error);
        expect(cubit.state.errorMessage, contains('Update failed'));

        repo.deleteStockError = Exception('Delete failed');
        await cubit.deleteStockItem('stock-1');
        expect(cubit.state.status, PharmacyStatus.error);
        expect(cubit.state.errorMessage, contains('Delete failed'));
      });
    });

    group('Live Stock Stream and Lifecycle', () {
      test(
        'subscribeToStock updates stockItems and preserves pharmacy',
        () async {
          repo.pharmacyByOwnerResult = testPharmacy;
          await cubit.loadPharmacy('partner-user-123');

          final streamController =
              StreamController<List<StockItemEntity>>.broadcast();
          repo.streamController = streamController;

          await cubit.subscribeToStock('pharm-1');

          final updatedItems = [
            testStock,
            StockItemEntity(
              id: 'stock-live-1',
              pharmacyId: 'pharm-1',
              pharmacyName: 'City Care Pharmacy',
              pharmacyArea: 'Kacyiru',
              pharmacyPhone: '+250 788 111 222',
              pharmacyHours: '8:00 AM - 10:00 PM',
              pharmacyLat: -1.944,
              pharmacyLng: 30.061,
              medicineName: 'Cetirizine 10mg',
              status: 'in_stock',
              quantity: 200,
              price: 800,
              updatedAt: DateTime(2025, 1, 6),
            ),
          ];

          streamController.add(updatedItems);
          await pumpEventQueue();

          expect(cubit.state.status, PharmacyStatus.loaded);
          expect(cubit.state.pharmacy, equals(testPharmacy));
          expect(cubit.state.stockItems, equals(updatedItems));

          await streamController.close();
        },
      );

      test('re-subscribing cancels previous subscription cleanly', () async {
        final stream1 = StreamController<List<StockItemEntity>>.broadcast();
        final stream2 = StreamController<List<StockItemEntity>>.broadcast();

        repo.streamController = stream1;
        await cubit.subscribeToStock('pharm-1');

        repo.streamController = stream2;
        await cubit.subscribeToStock('pharm-2');

        stream1.add([testStock]);
        await pumpEventQueue();

        // stream1 emission should be ignored since subscription was cancelled
        expect(cubit.state.stockItems, isEmpty);

        final stock2 = StockItemEntity(
          id: 'stock-pharm-2',
          pharmacyId: 'pharm-2',
          pharmacyName: 'Pharmacy 2',
          pharmacyArea: 'Nyarutarama',
          pharmacyPhone: '+250 788 555 666',
          pharmacyHours: '8:00 AM - 10:00 PM',
          pharmacyLat: -1.93,
          pharmacyLng: 30.08,
          medicineName: 'Zinc 20mg',
          status: 'in_stock',
          quantity: 40,
          price: 500,
          updatedAt: DateTime(2025, 1, 7),
        );

        stream2.add([stock2]);
        await pumpEventQueue();

        expect(cubit.state.stockItems, [stock2]);

        await stream1.close();
        await stream2.close();
      });

      test(
        'stream error emits error status without discarding pharmacy',
        () async {
          repo.pharmacyByOwnerResult = testPharmacy;
          await cubit.loadPharmacy('partner-user-123');

          final streamController =
              StreamController<List<StockItemEntity>>.broadcast();
          repo.streamController = streamController;

          await cubit.subscribeToStock('pharm-1');

          streamController.addError(Exception('Stream disconnected'));
          await pumpEventQueue();

          expect(cubit.state.status, PharmacyStatus.error);
          expect(cubit.state.pharmacy, equals(testPharmacy));
          expect(cubit.state.errorMessage, contains('Stream disconnected'));

          await streamController.close();
        },
      );

      test('cancelStockSubscription cancels stream listener', () async {
        final streamController =
            StreamController<List<StockItemEntity>>.broadcast();
        repo.streamController = streamController;

        await cubit.subscribeToStock('pharm-1');
        await cubit.cancelStockSubscription();

        streamController.add([testStock]);
        await pumpEventQueue();

        expect(cubit.state.stockItems, isEmpty);

        await streamController.close();
      });

      test('close cancels active subscription cleanly', () async {
        final streamController =
            StreamController<List<StockItemEntity>>.broadcast();
        repo.streamController = streamController;

        await cubit.subscribeToStock('pharm-1');
        await cubit.close();

        // Should not throw and cubit is closed
        expect(cubit.isClosed, isTrue);

        await streamController.close();
      });

      test(
        'does not emit state when stream event arrives after close',
        () async {
          final streamController =
              StreamController<List<StockItemEntity>>.broadcast();
          repo.streamController = streamController;

          await cubit.subscribeToStock('pharm-1');
          await cubit.close();

          // Adding to stream after cubit is closed should not throw or cause StateError
          streamController.add([testStock]);
          await pumpEventQueue();

          expect(cubit.isClosed, isTrue);
          await streamController.close();
        },
      );
    });
  });
}
