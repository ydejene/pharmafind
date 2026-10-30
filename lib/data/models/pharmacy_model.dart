import 'package:equatable/equatable.dart';

class PharmacyModel extends Equatable {
  final String id;
  final String name;
  final String area;
  final String district;
  final String phone;
  final String email;
  final String hours;
  final double latitude;
  final double longitude;
  final String ownerId;
  final String status;
  final bool acceptsInsurance;
  final DateTime createdAt;

  const PharmacyModel({
    required this.id,
    required this.name,
    required this.area,
    required this.district,
    required this.phone,
    required this.email,
    required this.hours,
    required this.latitude,
    required this.longitude,
    required this.ownerId,
    this.status = 'pending',
    this.acceptsInsurance = true,
    required this.createdAt,
  });

  factory PharmacyModel.fromMap(Map<String, dynamic> data, String id) {
    return PharmacyModel(
      id: id,
      name: data['name'] ?? '',
      area: data['area'] ?? '',
      district: data['district'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      hours: data['hours'] ?? '',
      latitude: (data['latitude'] ?? -1.9403).toDouble(),
      longitude: (data['longitude'] ?? 29.8739).toDouble(),
      ownerId: data['ownerId'] ?? '',
      status: data['status'] ?? 'pending',
      acceptsInsurance: data['acceptsInsurance'] ?? true,
      createdAt: data['createdAt'] is DateTime
          ? data['createdAt']
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'area': area,
      'district': district,
      'phone': phone,
      'email': email,
      'hours': hours,
      'latitude': latitude,
      'longitude': longitude,
      'ownerId': ownerId,
      'status': status,
      'acceptsInsurance': acceptsInsurance,
      'createdAt': createdAt,
    };
  }

  PharmacyModel copyWith({
    String? name,
    String? area,
    String? district,
    String? phone,
    String? email,
    String? hours,
    double? latitude,
    double? longitude,
    String? status,
    bool? acceptsInsurance,
  }) {
    return PharmacyModel(
      id: id,
      name: name ?? this.name,
      area: area ?? this.area,
      district: district ?? this.district,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      hours: hours ?? this.hours,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      ownerId: ownerId,
      status: status ?? this.status,
      acceptsInsurance: acceptsInsurance ?? this.acceptsInsurance,
      createdAt: createdAt,
    );
  }

  double distanceText(double userLat, double userLng) {
    const double earthRadius = 6371;
    final dLat = _toRadians(latitude - userLat);
    final dLng = _toRadians(longitude - userLng);
    final a =
        _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(userLat)) *
            _cos(_toRadians(latitude)) *
            _sin(dLng / 2) *
            _sin(dLng / 2);
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double deg) => deg * 3.14159265359 / 180;
  static double _sin(double x) {
    double result = x;
    double term = x;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  static double _cos(double x) => _sin(x + 1.5707963268);
  static double _sqrt(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 20; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  static double _atan2(double y, double x) {
    if (x > 0) return _atan(y / x);
    if (x < 0 && y >= 0) return _atan(y / x) + 3.14159265359;
    if (x < 0 && y < 0) return _atan(y / x) - 3.14159265359;
    if (y > 0) return 1.5707963268;
    if (y < 0) return -1.5707963268;
    return 0;
  }

  static double _atan(double x) {
    double result = x;
    double term = x;
    for (int i = 1; i <= 15; i++) {
      term *= -x * x;
      result += term / (2 * i + 1);
    }
    return result;
  }

  @override
  List<Object?> get props => [id, name, area, district, ownerId, status];
}
