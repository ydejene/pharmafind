import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;
  final String role;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.displayName,
    this.role = 'patient',
  });

  @override
  List<Object?> get props => [email, password, displayName, role];
}

class AuthGoogleSignInRequested extends AuthEvent {}

class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthProfileUpdateRequested extends AuthEvent {
  final String? insuranceProvider;
  final String? insuranceId;
  final String? phone;

  const AuthProfileUpdateRequested({
    this.insuranceProvider,
    this.insuranceId,
    this.phone,
  });

  @override
  List<Object?> get props => [insuranceProvider, insuranceId, phone];
}
