class AuthException implements Exception {
  final String code;
  final String message;

  const AuthException({required this.code, required this.message});

  factory AuthException.invalidCredentials() => const AuthException(
    code: 'invalid-credentials',
    message: 'Invalid email or password. Please try again.',
  );

  factory AuthException.emailAlreadyInUse() => const AuthException(
    code: 'email-already-in-use',
    message: 'An account with this email already exists.',
  );

  factory AuthException.weakPassword() => const AuthException(
    code: 'weak-password',
    message: 'Password is too weak. Use at least 6 characters.',
  );

  factory AuthException.userNotFound() => const AuthException(
    code: 'user-not-found',
    message: 'No account found with this email.',
  );

  factory AuthException.networkError() => const AuthException(
    code: 'network-error',
    message: 'Network error. Please check your connection.',
  );

  @override
  String toString() => message;
}
