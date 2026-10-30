import 'auth_event.dart';

extension AuthEventDescription on AuthEvent {
  String get description {
    if (this is AuthLoginRequested) return 'Login attempt';
    if (this is AuthRegisterRequested) return 'Registration attempt';
    if (this is AuthGoogleSignInRequested) return 'Google sign-in attempt';
    if (this is AuthPasswordResetRequested) return 'Password reset request';
    if (this is AuthLogoutRequested) return 'Logout';
    if (this is AuthCheckRequested) return 'Auth status check';
    if (this is AuthProfileUpdateRequested) return 'Profile update';
    return 'Unknown auth event';
  }

  bool get requiresNetwork {
    return this is AuthLoginRequested ||
        this is AuthRegisterRequested ||
        this is AuthGoogleSignInRequested ||
        this is AuthPasswordResetRequested;
  }

  bool get mutatesState {
    return this is! AuthCheckRequested;
  }
}

class AuthDeleteAccountRequested extends AuthEvent {
  final String confirmEmail;

  const AuthDeleteAccountRequested({required this.confirmEmail});

  @override
  List<Object?> get props => [confirmEmail];
}
