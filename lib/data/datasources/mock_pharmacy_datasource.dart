import 'dart:async';

import '../models/pharmacy_model.dart';
import '../models/stock_item_model.dart';
import 'pharmacy_datasource.dart';

class MockPharmacyDataSource implements IPharmacyDataSource {
  final Map<String, PharmacyModel> _pharmacies = {};
  final Map<String, StockItemModel> _stock = {};
  final StreamController<void> _stockChangeController =
      StreamController<void>.broadcast();
  int _idCounter = 100;

  MockPharmacyDataSource({bool seedInitialData = true}) {
    if (seedInitialData) {
      _seedData();
    }
  }

  void _seedData() {
    final pharmacies = [
      PharmacyModel(
        id: 'pharm-1',
        name: 'Teta Pharmacy',
        area: 'Kimironko',
        district: 'Gasabo',
        phone: '+250 789 771 322',
        email: '',
        hours: '7:00 AM - 11:00 PM',
        latitude: -1.9496804,
        longitude: 30.1249144,
        ownerId: 'owner-1',
        status: 'approved',
        acceptsInsurance: true,
        createdAt: DateTime(2024, 1, 15),
      ),
      PharmacyModel(
        id: 'pharm-2',
        name: 'Pharmacie Conseil',
        area: 'Nyarutarama',
        district: 'Gasabo',
        phone: '+250 788 381 219',
        email: '',
        hours: '7:30 AM - 10:00 PM (Mon-Sat); 10:00 AM - 3:00 PM (Sun)',
        latitude: -1.93661,
        longitude: 30.09934,
        ownerId: 'owner-2',
        status: 'approved',
        acceptsInsurance: true,
        createdAt: DateTime(2024, 3, 10),
      ),
      PharmacyModel(
        id: 'pharm-3',
        name: 'Kipharma Remera',
        area: 'Remera',
        district: 'Gasabo',
        phone: '+250 280 123 001',
        email: '',
        hours: '8:00 AM - 9:00 PM (Mon-Sat); 11:00 AM - 7:00 PM (Sun)',
        latitude: -1.95814,
        longitude: 30.11159,
        ownerId: 'owner-3',
        status: 'approved',
        acceptsInsurance: false,
        createdAt: DateTime(2024, 6, 1),
      ),
      PharmacyModel(
        id: 'pharm-4',
        name: 'Tercera Pharmacy',
        area: 'Kimihurura',
        district: 'Gasabo',
        phone: '+250 788 700 806',
        email: '',
        hours: '',
        latitude: -1.9525,
        longitude: 30.0925,
        ownerId: 'owner-4',
        status: 'approved',
        acceptsInsurance: true,
        createdAt: DateTime(2024, 2, 20),
      ),
    ];

    for (final p in pharmacies) {
      _pharmacies[p.id] = p;
    }

    final stockItems = [
      StockItemModel(
        id: 'stock-1',
        pharmacyId: 'pharm-1',
        pharmacyName: 'Teta Pharmacy',
        pharmacyArea: 'Kimironko',
        pharmacyPhone: '+250 789 771 322',
        pharmacyHours: '7:00 AM - 11:00 PM',
        pharmacyLat: -1.9496804,
        pharmacyLng: 30.1249144,
        medicineName: 'Amoxicillin 500mg',
        status: 'in_stock',
        quantity: 42,
        price: 3500,
        updatedAt: DateTime(2025, 1, 10, 8, 30),
      ),
      StockItemModel(
        id: 'stock-2',
        pharmacyId: 'pharm-1',
        pharmacyName: 'Teta Pharmacy',
        pharmacyArea: 'Kimironko',
        pharmacyPhone: '+250 789 771 322',
        pharmacyHours: '7:00 AM - 11:00 PM',
        pharmacyLat: -1.9496804,
        pharmacyLng: 30.1249144,
        medicineName: 'Paracetamol 1000mg',
        status: 'in_stock',
        quantity: 120,
        price: 500,
        updatedAt: DateTime(2025, 1, 10, 9, 0),
      ),
      StockItemModel(
        id: 'stock-3',
        pharmacyId: 'pharm-2',
        pharmacyName: 'Pharmacie Conseil',
        pharmacyArea: 'Nyarutarama',
        pharmacyPhone: '+250 788 381 219',
        pharmacyHours: '7:30 AM - 10:00 PM (Mon-Sat); 10:00 AM - 3:00 PM (Sun)',
        pharmacyLat: -1.93661,
        pharmacyLng: 30.09934,
        medicineName: 'Amoxicillin 500mg',
        status: 'low_stock',
        quantity: 5,
        price: 4000,
        updatedAt: DateTime(2025, 1, 11, 10, 15),
      ),
      StockItemModel(
        id: 'stock-4',
        pharmacyId: 'pharm-2',
        pharmacyName: 'Pharmacie Conseil',
        pharmacyArea: 'Nyarutarama',
        pharmacyPhone: '+250 788 381 219',
        pharmacyHours: '7:30 AM - 10:00 PM (Mon-Sat); 10:00 AM - 3:00 PM (Sun)',
        pharmacyLat: -1.93661,
        pharmacyLng: 30.09934,
        medicineName: 'Ibuprofen 400mg',
        status: 'in_stock',
        quantity: 75,
        price: 2000,
        updatedAt: DateTime(2025, 1, 11, 11, 45),
      ),
      StockItemModel(
        id: 'stock-5',
        pharmacyId: 'pharm-3',
        pharmacyName: 'Kipharma Remera',
        pharmacyArea: 'Remera',
        pharmacyPhone: '+250 280 123 001',
        pharmacyHours: '8:00 AM - 9:00 PM (Mon-Sat); 11:00 AM - 7:00 PM (Sun)',
        pharmacyLat: -1.95814,
        pharmacyLng: 30.11159,
        medicineName: 'Metformin 500mg',
        status: 'in_stock',
        quantity: 60,
        price: 8500,
        updatedAt: DateTime(2025, 1, 12, 7, 0),
      ),
      StockItemModel(
        id: 'stock-6',
        pharmacyId: 'pharm-3',
        pharmacyName: 'Kipharma Remera',
        pharmacyArea: 'Remera',
        pharmacyPhone: '+250 280 123 001',
        pharmacyHours: '8:00 AM - 9:00 PM (Mon-Sat); 11:00 AM - 7:00 PM (Sun)',
        pharmacyLat: -1.95814,
        pharmacyLng: 30.11159,
        medicineName: 'Paracetamol 1000mg',
        status: 'in_stock',
        quantity: 200,
        price: 450,
        updatedAt: DateTime(2025, 1, 12, 8, 15),
      ),
      StockItemModel(
        id: 'stock-7',
        pharmacyId: 'pharm-4',
        pharmacyName: 'Tercera Pharmacy',
        pharmacyArea: 'Kimihurura',
        pharmacyPhone: '+250 788 700 806',
        pharmacyHours: '',
        pharmacyLat: -1.9525,
        pharmacyLng: 30.0925,
        medicineName: 'Omeprazole 20mg',
        status: 'in_stock',
        quantity: 35,
        price: 6000,
        updatedAt: DateTime(2025, 1, 13, 9, 30),
      ),
      StockItemModel(
        id: 'stock-8',
        pharmacyId: 'pharm-4',
        pharmacyName: 'Tercera Pharmacy',
        pharmacyArea: 'Kimihurura',
        pharmacyPhone: '+250 788 700 806',
        pharmacyHours: '',
        pharmacyLat: -1.9525,
        pharmacyLng: 30.0925,
        medicineName: 'Amoxicillin 500mg',
        status: 'out_of_stock',
        quantity: 0,
        price: 3800,
        updatedAt: DateTime(2025, 1, 13, 10, 0),
      ),
    ];

    for (final s in stockItems) {
      _stock[s.id] = s;
    }
  }

  String _nextId(String prefix) => '$prefix-${_idCounter++}';

  @override
  Future<String> createPharmacy(PharmacyModel pharmacy) async {
    final id = pharmacy.id.isNotEmpty ? pharmacy.id : _nextId('pharm');
    final created = PharmacyModel(
      id: id,
      name: pharmacy.name,
      area: pharmacy.area,
      district: pharmacy.district,
      phone: pharmacy.phone,
      email: pharmacy.email,
      hours: pharmacy.hours,
      latitude: pharmacy.latitude,
      longitude: pharmacy.longitude,
      ownerId: pharmacy.ownerId,
      status: pharmacy.status,
      acceptsInsurance: pharmacy.acceptsInsurance,
      createdAt: pharmacy.createdAt,
    );
    _pharmacies[id] = created;
    return id;
  }

  @override
  Future<void> updatePharmacy(PharmacyModel pharmacy) async {
    _pharmacies[pharmacy.id] = pharmacy;
  }

  @override
  Future<void> deletePharmacy(String pharmacyId) async {
    _pharmacies.remove(pharmacyId);
    _stock.removeWhere((_, item) => item.pharmacyId == pharmacyId);
    _stockChangeController.add(null);
  }

  @override
  Future<PharmacyModel?> getPharmacy(String pharmacyId) async {
    return _pharmacies[pharmacyId];
  }

  @override
  Future<List<PharmacyModel>> getApprovedPharmacies() async {
    return _pharmacies.values
        .where((p) => p.status == 'approved')
        .map((p) => p)
        .toList();
  }

  @override
  Future<PharmacyModel?> getPharmacyByOwner(String ownerId) async {
    try {
      return _pharmacies.values.firstWhere((p) => p.ownerId == ownerId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<StockItemModel>> searchMedicine(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return [];

    return _stock.values
        .where(
          (item) =>
              item.medicineName.toLowerCase().contains(normalized) &&
              item.status != 'out_of_stock',
        )
        .toList();
  }

  @override
  Future<String> addStockItem(StockItemModel item) async {
    final id = item.id.isNotEmpty ? item.id : _nextId('stock');
    final created = StockItemModel(
      id: id,
      pharmacyId: item.pharmacyId,
      pharmacyName: item.pharmacyName,
      pharmacyArea: item.pharmacyArea,
      pharmacyPhone: item.pharmacyPhone,
      pharmacyHours: item.pharmacyHours,
      pharmacyLat: item.pharmacyLat,
      pharmacyLng: item.pharmacyLng,
      medicineName: item.medicineName,
      status: item.status,
      quantity: item.quantity,
      price: item.price,
      updatedAt: item.updatedAt,
    );
    _stock[id] = created;
    _stockChangeController.add(null);
    return id;
  }

  @override
  Future<void> updateStockItem(StockItemModel item) async {
    _stock[item.id] = item;
    _stockChangeController.add(null);
  }

  @override
  Future<void> deleteStockItem(String stockId) async {
    _stock.remove(stockId);
    _stockChangeController.add(null);
  }

  @override
  Future<List<StockItemModel>> getPharmacyStock(String pharmacyId) async {
    return _stock.values
        .where((item) => item.pharmacyId == pharmacyId)
        .toList();
  }

  @override
  Stream<List<StockItemModel>> watchPharmacyStock(String pharmacyId) async* {
    yield await getPharmacyStock(pharmacyId);
    yield* _stockChangeController.stream.asyncMap(
      (_) => getPharmacyStock(pharmacyId),
    );
  }
}
