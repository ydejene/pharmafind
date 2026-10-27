import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_find/data/models/stock_item_model.dart';

void main() {
  group('StockItemModel', () {
    late StockItemModel item;

    setUp(() {
      item = StockItemModel(
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
        updatedAt: DateTime.now(),
      );
    });

    test('formattedPrice formats correctly', () {
      expect(item.formattedPrice, 'RWF 3,500');
    });

    test('formattedPrice handles large numbers', () {
      final expensive = StockItemModel(
        id: '1',
        pharmacyId: '1',
        pharmacyName: 'Test',
        medicineName: 'Test',
        price: 125000,
        updatedAt: DateTime.now(),
      );
      expect(expensive.formattedPrice, 'RWF 125,000');
    });

    test('timeAgo returns just now for recent items', () {
      expect(item.timeAgo, 'just now');
    });

    test('timeAgo returns minutes for older items', () {
      final older = StockItemModel(
        id: '1',
        pharmacyId: '1',
        pharmacyName: 'Test',
        medicineName: 'Test',
        updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      );
      expect(older.timeAgo, '15 min ago');
    });

    test('timeAgo returns hours for much older items', () {
      final hoursOld = StockItemModel(
        id: '1',
        pharmacyId: '1',
        pharmacyName: 'Test',
        medicineName: 'Test',
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      );
      expect(hoursOld.timeAgo, '3 hr ago');
    });

    test('copyWith updates specified fields', () {
      final updated = item.copyWith(quantity: 10, status: 'low_stock');

      expect(updated.quantity, 10);
      expect(updated.status, 'low_stock');
      expect(updated.medicineName, 'Amoxicillin 500mg');
      expect(updated.pharmacyName, 'Green Health Pharmacy');
    });
  });
}
