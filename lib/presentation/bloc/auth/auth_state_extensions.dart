import 'auth_state.dart';

extension AuthStateX on AuthState {
  bool get isLoading => this is AuthLoading;
  bool get isAuthenticated => this is AuthAuthenticated;
  bool get isUnauthenticated => this is AuthUnauthenticated;
  bool get hasError => this is AuthError;
  bool get isPasswordResetSent => this is AuthPasswordResetSent;

  String? get errorMessage {
    if (this is AuthError) {
      return (this as AuthError).message;
    }
    return null;
  }

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(AuthAuthenticated) authenticated,
    required T Function() unauthenticated,
    required T Function(String message) error,
    required T Function() passwordResetSent,
  }) {
    if (this is AuthInitial) return initial();
    if (this is AuthLoading) return loading();
    if (this is AuthAuthenticated) {
      return authenticated(this as AuthAuthenticated);
    }
    if (this is AuthError) return error((this as AuthError).message);
    if (this is AuthPasswordResetSent) return passwordResetSent();
    return unauthenticated();
  }
}
