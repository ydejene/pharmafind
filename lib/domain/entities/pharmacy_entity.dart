import 'package:equatable/equatable.dart';

class PharmacyEntity extends Equatable {
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

  const PharmacyEntity({
    required this.id,
    required this.name,
    required this.area,
    this.district = 'Gasabo',
    required this.phone,
    required this.email,
    this.hours = '8:00 AM - 10:00 PM',
    required this.latitude,
    required this.longitude,
    required this.ownerId,
    this.status = 'approved',
    this.acceptsInsurance = true,
    required this.createdAt,
  });

  bool get isApproved => status == 'approved';

  @override
  List<Object?> get props => [
    id,
    name,
    area,
    district,
    phone,
    email,
    hours,
    latitude,
    longitude,
    ownerId,
    status,
    acceptsInsurance,
    createdAt,
  ];
}
