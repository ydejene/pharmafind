import '../models/pharmacy_model.dart';
import '../models/stock_item_model.dart';

class PharmacyRepository {
  final Map<String, PharmacyModel> _pharmacies = {};
  final Map<String, StockItemModel> _stock = {};
  int _idCounter = 100;

  PharmacyRepository() {
    _seedData();
  }

  void _seedData() {
    final pharmacies = [
      PharmacyModel(
        id: 'pharm-1',
        name: 'Green Health Pharmacy',
        area: 'Kimironko',
        district: 'Gasabo',
        phone: '+250 788 123 456',
        email: 'info@greenhealth.rw',
        hours: '7:00 AM - 9:00 PM',
        latitude: -1.9441,
        longitude: 29.8739,
        ownerId: 'owner-1',
        status: 'approved',
        createdAt: DateTime(2024, 1, 15),
      ),
      PharmacyModel(
        id: 'pharm-2',
        name: 'Kigali Pharma Plus',
        area: 'Nyarutarama',
        district: 'Gasabo',
        phone: '+250 788 654 321',
        email: 'contact@kigalipharma.rw',
        hours: '8:00 AM - 10:00 PM',
        latitude: -1.9380,
        longitude: 29.8800,
        ownerId: 'owner-2',
        status: 'approved',
        createdAt: DateTime(2024, 3, 10),
      ),
      PharmacyModel(
        id: 'pharm-3',
        name: 'Remera Medical Store',
        area: 'Remera',
        district: 'Gasabo',
        phone: '+250 788 111 222',
        email: 'remera@medstore.rw',
        hours: '6:30 AM - 8:00 PM',
        latitude: -1.9560,
        longitude: 29.8830,
        ownerId: 'owner-3',
        status: 'approved',
        createdAt: DateTime(2024, 6, 1),
      ),
      PharmacyModel(
        id: 'pharm-4',
        name: 'Pharmacie de Kacyiru',
        area: 'Kacyiru',
        district: 'Gasabo',
        phone: '+250 788 333 444',
        email: 'kacyiru@pharma.rw',
        hours: '7:00 AM - 9:30 PM',
        latitude: -1.9350,
        longitude: 29.8650,
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
        pharmacyName: 'Green Health Pharmacy',
        pharmacyArea: 'Kimironko',
        pharmacyPhone: '+250 788 123 456',
        pharmacyHours: '7:00 AM - 9:00 PM',
        pharmacyLat: -1.9441,
        pharmacyLng: 29.8739,
        medicineName: 'Amoxicillin 500mg',
        status: 'in_stock',
        quantity: 42,
        price: 3500,
        updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      StockItemModel(
        id: 'stock-2',
        pharmacyId: 'pharm-1',
        pharmacyName: 'Green Health Pharmacy',
        pharmacyArea: 'Kimironko',
        pharmacyPhone: '+250 788 123 456',
        pharmacyHours: '7:00 AM - 9:00 PM',
        pharmacyLat: -1.9441,
        pharmacyLng: 29.8739,
        medicineName: 'Paracetamol 1000mg',
        status: 'in_stock',
        quantity: 120,
        price: 500,
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      StockItemModel(
        id: 'stock-3',
        pharmacyId: 'pharm-2',
        pharmacyName: 'Kigali Pharma Plus',
        pharmacyArea: 'Nyarutarama',
        pharmacyPhone: '+250 788 654 321',
        pharmacyHours: '8:00 AM - 10:00 PM',
        pharmacyLat: -1.9380,
        pharmacyLng: 29.8800,
        medicineName: 'Amoxicillin 500mg',
        status: 'low_stock',
        quantity: 5,
        price: 4000,
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      StockItemModel(
        id: 'stock-4',
        pharmacyId: 'pharm-2',
        pharmacyName: 'Kigali Pharma Plus',
        pharmacyArea: 'Nyarutarama',
        pharmacyPhone: '+250 788 654 321',
        pharmacyHours: '8:00 AM - 10:00 PM',
        pharmacyLat: -1.9380,
        pharmacyLng: 29.8800,
        medicineName: 'Ibuprofen 400mg',
        status: 'in_stock',
        quantity: 75,
        price: 2000,
        updatedAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      StockItemModel(
        id: 'stock-5',
        pharmacyId: 'pharm-3',
        pharmacyName: 'Remera Medical Store',
        pharmacyArea: 'Remera',
        pharmacyPhone: '+250 788 111 222',
        pharmacyHours: '6:30 AM - 8:00 PM',
        pharmacyLat: -1.9560,
        pharmacyLng: 29.8830,
        medicineName: 'Metformin 500mg',
        status: 'in_stock',
        quantity: 60,
        price: 8500,
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      StockItemModel(
        id: 'stock-6',
        pharmacyId: 'pharm-3',
        pharmacyName: 'Remera Medical Store',
        pharmacyArea: 'Remera',
        pharmacyPhone: '+250 788 111 222',
        pharmacyHours: '6:30 AM - 8:00 PM',
        pharmacyLat: -1.9560,
        pharmacyLng: 29.8830,
        medicineName: 'Paracetamol 1000mg',
        status: 'in_stock',
        quantity: 200,
        price: 450,
        updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      StockItemModel(
        id: 'stock-7',
        pharmacyId: 'pharm-4',
        pharmacyName: 'Pharmacie de Kacyiru',
        pharmacyArea: 'Kacyiru',
        pharmacyPhone: '+250 788 333 444',
        pharmacyHours: '7:00 AM - 9:30 PM',
        pharmacyLat: -1.9350,
        pharmacyLng: 29.8650,
        medicineName: 'Omeprazole 20mg',
        status: 'in_stock',
        quantity: 35,
        price: 6000,
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      StockItemModel(
        id: 'stock-8',
        pharmacyId: 'pharm-4',
        pharmacyName: 'Pharmacie de Kacyiru',
        pharmacyArea: 'Kacyiru',
        pharmacyPhone: '+250 788 333 444',
        pharmacyHours: '7:00 AM - 9:30 PM',
        pharmacyLat: -1.9350,
        pharmacyLng: 29.8650,
        medicineName: 'Amoxicillin 500mg',
        status: 'out_of_stock',
        quantity: 0,
        price: 3800,
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    for (final s in stockItems) {
      _stock[s.id] = s;
    }
  }

  String _nextId() => 'gen-${_idCounter++}';

  Future<String> createPharmacy(PharmacyModel pharmacy) async {
    final id = _nextId();
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

  Future<void> updatePharmacy(PharmacyModel pharmacy) async {
    _pharmacies[pharmacy.id] = pharmacy;
  }

  Future<void> deletePharmacy(String pharmacyId) async {
    _pharmacies.remove(pharmacyId);
    _stock.removeWhere((_, item) => item.pharmacyId == pharmacyId);
  }

  Future<PharmacyModel?> getPharmacy(String pharmacyId) async {
    return _pharmacies[pharmacyId];
  }

  Future<List<PharmacyModel>> getApprovedPharmacies() async {
    return _pharmacies.values
        .where((p) => p.status == 'approved')
        .toList();
  }

  Future<PharmacyModel?> getPharmacyByOwner(String ownerId) async {
    try {
      return _pharmacies.values.firstWhere((p) => p.ownerId == ownerId);
    } catch (_) {
      return null;
    }
  }

  Future<List<StockItemModel>> searchMedicine(String query) async {
    final normalizedQuery = query.trim().toLowerCase();
    await Future.delayed(const Duration(milliseconds: 200));
    return _stock.values
        .where((item) =>
            item.medicineName.toLowerCase().contains(normalizedQuery) &&
            item.status != 'out_of_stock')
        .toList();
  }

  Future<String> addStockItem(StockItemModel item) async {
    final id = _nextId();
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
    return id;
  }

  Future<void> updateStockItem(StockItemModel item) async {
    _stock[item.id] = item;
  }

  Future<void> deleteStockItem(String stockId) async {
    _stock.remove(stockId);
  }

  Future<List<StockItemModel>> getPharmacyStock(String pharmacyId) async {
    return _stock.values
        .where((item) => item.pharmacyId == pharmacyId)
        .toList();
  }

  Stream<List<StockItemModel>> watchPharmacyStock(String pharmacyId) {
    return Stream.value(
      _stock.values
          .where((item) => item.pharmacyId == pharmacyId)
          .toList(),
    );
  }
}
