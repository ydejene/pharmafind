import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String role;
  final String? insuranceProvider;
  final String? insuranceId;
  final String? phone;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.role = 'patient',
    this.insuranceProvider,
    this.insuranceId,
    this.phone,
    required this.createdAt,
  });

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      displayName: entity.displayName,
      role: entity.role,
      insuranceProvider: entity.insuranceProvider,
      insuranceId: entity.insuranceId,
      phone: entity.phone,
      createdAt: entity.createdAt,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      email: email,
      displayName: displayName,
      role: role,
      insuranceProvider: insuranceProvider,
      insuranceId: insuranceId,
      phone: phone,
      createdAt: createdAt,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      role: data['role'] ?? 'patient',
      insuranceProvider: data['insuranceProvider'],
      insuranceId: data['insuranceId'],
      phone: data['phone'],
      createdAt: data['createdAt'] is DateTime
          ? data['createdAt']
          : (data['createdAt'] is String
                ? DateTime.tryParse(data['createdAt']) ?? DateTime.now()
                : DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
      'insuranceProvider': insuranceProvider,
      'insuranceId': insuranceId,
      'phone': phone,
      'createdAt': createdAt,
    };
  }

  UserModel copyWith({
    String? displayName,
    String? role,
    String? insuranceProvider,
    String? insuranceId,
    String? phone,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      insuranceId: insuranceId ?? this.insuranceId,
      phone: phone ?? this.phone,
      createdAt: createdAt,
    );
  }

  bool get isPartner => role == 'partner';
  bool get isAdmin => role == 'admin';
  bool get isPatient => role == 'patient';

  @override
  List<Object?> get props => [
    uid,
    email,
    displayName,
    role,
    insuranceProvider,
    insuranceId,
    phone,
    createdAt,
  ];
}
