import 'package:equatable/equatable.dart';

class StockItemModel extends Equatable {
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

  const StockItemModel({
    required this.id,
    required this.pharmacyId,
    required this.pharmacyName,
    this.pharmacyArea = '',
    this.pharmacyPhone = '',
    this.pharmacyHours = '',
    this.pharmacyLat = -1.9403,
    this.pharmacyLng = 29.8739,
    required this.medicineName,
    this.status = 'in_stock',
    this.quantity = 0,
    this.price = 0,
    required this.updatedAt,
  });

  factory StockItemModel.fromMap(Map<String, dynamic> data, String id) {
    return StockItemModel(
      id: id,
      pharmacyId: data['pharmacyId'] ?? '',
      pharmacyName: data['pharmacyName'] ?? '',
      pharmacyArea: data['pharmacyArea'] ?? '',
      pharmacyPhone: data['pharmacyPhone'] ?? '',
      pharmacyHours: data['pharmacyHours'] ?? '',
      pharmacyLat: (data['pharmacyLat'] ?? -1.9403).toDouble(),
      pharmacyLng: (data['pharmacyLng'] ?? 29.8739).toDouble(),
      medicineName: data['medicineName'] ?? '',
      status: data['status'] ?? 'in_stock',
      quantity: data['quantity'] ?? 0,
      price: data['price'] ?? 0,
      updatedAt: data['updatedAt'] is DateTime
          ? data['updatedAt']
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pharmacyId': pharmacyId,
      'pharmacyName': pharmacyName,
      'pharmacyArea': pharmacyArea,
      'pharmacyPhone': pharmacyPhone,
      'pharmacyHours': pharmacyHours,
      'pharmacyLat': pharmacyLat,
      'pharmacyLng': pharmacyLng,
      'medicineName': medicineName,
      'status': status,
      'quantity': quantity,
      'price': price,
      'updatedAt': updatedAt,
    };
  }

  StockItemModel copyWith({
    String? status,
    int? quantity,
    int? price,
    DateTime? updatedAt,
  }) {
    return StockItemModel(
      id: id,
      pharmacyId: pharmacyId,
      pharmacyName: pharmacyName,
      pharmacyArea: pharmacyArea,
      pharmacyPhone: pharmacyPhone,
      pharmacyHours: pharmacyHours,
      pharmacyLat: pharmacyLat,
      pharmacyLng: pharmacyLng,
      medicineName: medicineName,
      status: status ?? this.status,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedPrice =>
      'RWF ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}';

  String get timeAgo {
    final diff = DateTime.now().difference(updatedAt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} days ago';
  }

  @override
  List<Object?> get props => [
    id,
    pharmacyId,
    medicineName,
    status,
    quantity,
    price,
  ];
}
