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

  // Verification metadata
  final String? licenseUrl;
  final String? licensePublicId;
  final String? rmohCertUrl;
  final String? rmohCertPublicId;
  final DateTime? submittedAt;
  final String? rejectionReason;
  final DateTime? reviewedAt;
  final String? reviewedBy;

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
    this.licenseUrl,
    this.licensePublicId,
    this.rmohCertUrl,
    this.rmohCertPublicId,
    this.submittedAt,
    this.rejectionReason,
    this.reviewedAt,
    this.reviewedBy,
  });

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';
  bool get hasSubmittedDocuments => submittedAt != null;

  PharmacyEntity copyWith({
    String? id,
    String? name,
    String? area,
    String? district,
    String? phone,
    String? email,
    String? hours,
    double? latitude,
    double? longitude,
    String? ownerId,
    String? status,
    bool? acceptsInsurance,
    DateTime? createdAt,
    String? licenseUrl,
    String? licensePublicId,
    String? rmohCertUrl,
    String? rmohCertPublicId,
    DateTime? submittedAt,
    String? rejectionReason,
    DateTime? reviewedAt,
    String? reviewedBy,
  }) {
    return PharmacyEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      area: area ?? this.area,
      district: district ?? this.district,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      hours: hours ?? this.hours,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      ownerId: ownerId ?? this.ownerId,
      status: status ?? this.status,
      acceptsInsurance: acceptsInsurance ?? this.acceptsInsurance,
      createdAt: createdAt ?? this.createdAt,
      licenseUrl: licenseUrl ?? this.licenseUrl,
      licensePublicId: licensePublicId ?? this.licensePublicId,
      rmohCertUrl: rmohCertUrl ?? this.rmohCertUrl,
      rmohCertPublicId: rmohCertPublicId ?? this.rmohCertPublicId,
      submittedAt: submittedAt ?? this.submittedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
    );
  }

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
    licenseUrl,
    licensePublicId,
    rmohCertUrl,
    rmohCertPublicId,
    submittedAt,
    rejectionReason,
    reviewedAt,
    reviewedBy,
  ];
}
