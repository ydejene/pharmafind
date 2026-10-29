import '../constants/app_strings.dart';
import '../exceptions/auth_exception.dart';

class AuthErrorMapper {
  AuthErrorMapper._();

  static String toUserMessage(Object error, String locale) {
    if (error is AuthException) {
      return _mapAuthException(error, locale);
    }
    return AppStrings.get('error_generic', locale);
  }

  static String _mapAuthException(AuthException e, String locale) {
    switch (e.code) {
      case 'email-already-in-use':
        return AppStrings.get('error_email_taken', locale);
      case 'weak-password':
        return AppStrings.get('error_weak_password', locale);
      case 'user-not-found':
        return AppStrings.get('error_user_not_found', locale);
      case 'invalid-credentials':
        return AppStrings.get('error_invalid_credentials', locale);
      case 'network-error':
        return AppStrings.get('error_network', locale);
      default:
        return AppStrings.get('error_generic', locale);
    }
  }
}
