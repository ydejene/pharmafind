import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String role;
  final String? insuranceProvider;
  final String? insuranceId;
  final String? phone;
  final DateTime createdAt;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.displayName,
    this.role = 'patient',
    this.insuranceProvider,
    this.insuranceId,
    this.phone,
    required this.createdAt,
  });

  UserEntity copyWith({
    String? email,
    String? displayName,
    String? role,
    String? insuranceProvider,
    String? insuranceId,
    String? phone,
    DateTime? createdAt,
  }) {
    return UserEntity(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      insuranceId: insuranceId ?? this.insuranceId,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
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
