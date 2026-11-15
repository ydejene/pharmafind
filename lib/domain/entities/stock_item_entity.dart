import 'package:equatable/equatable.dart';

class StockItemEntity extends Equatable {
  final String id;
  final String pharmacyId;
  final String pharmacyName;
  final String pharmacyArea;
  final String pharmacyPhone;
  final String pharmacyHours;
  final double pharmacyLat;
  final double pharmacyLng;
  final String medicineName;
  final String status;
  final int quantity;
  final int price;
  final DateTime updatedAt;

  const StockItemEntity({
    required this.id,
    required this.pharmacyId,
    required this.pharmacyName,
    required this.pharmacyArea,
    required this.pharmacyPhone,
    required this.pharmacyHours,
    required this.pharmacyLat,
    required this.pharmacyLng,
    required this.medicineName,
    required this.status,
    required this.quantity,
    required this.price,
    required this.updatedAt,
  });

  String get formattedPrice =>
      'RWF ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}';

  String get timeAgo {
    final diff = DateTime.now().difference(updatedAt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} days ago';
  }

  bool get isInStock => status == 'in_stock';
  bool get isLowStock => status == 'low_stock';
  bool get isOutOfStock => status == 'out_of_stock';

  @override
  List<Object?> get props => [
    id,
    pharmacyId,
    pharmacyName,
    pharmacyArea,
    pharmacyPhone,
    pharmacyHours,
    pharmacyLat,
    pharmacyLng,
    medicineName,
    status,
    quantity,
    price,
    updatedAt,
  ];
}
