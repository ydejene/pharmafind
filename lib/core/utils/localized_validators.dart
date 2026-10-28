import '../constants/app_strings.dart';

class LocalizedValidators {
  LocalizedValidators._();

  static String? validateEmail(String? value, String locale) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.get('invalid_email', locale);
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return AppStrings.get('invalid_email', locale);
    }
    return null;
  }

  static String? validatePassword(String? value, String locale) {
    if (value == null || value.isEmpty) {
      return AppStrings.get('password_too_short', locale);
    }
    if (value.length < 6) {
      return AppStrings.get('password_too_short', locale);
    }
    return null;
  }

  static String? validateConfirmPassword(
    String? value,
    String password,
    String locale,
  ) {
    if (value == null || value.isEmpty) {
      return AppStrings.get('passwords_no_match', locale);
    }
    if (value != password) {
      return AppStrings.get('passwords_no_match', locale);
    }
    return null;
  }

  static String? validateName(String? value, String locale) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.get('name_required', locale);
    }
    return null;
  }
}
