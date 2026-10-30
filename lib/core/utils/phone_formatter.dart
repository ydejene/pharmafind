class PhoneFormatter {
  PhoneFormatter._();

  static const String rwandaPrefix = '+250';
  static const int rwandaLocalLength = 9;

  static String format(String input) {
    final digits = input.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.length <= 3) return digits;
    if (digits.length <= 6) {
      return '${digits.substring(0, 3)} ${digits.substring(3)}';
    }
    if (digits.length <= 9) {
      return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
    }
    return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6, 9)}';
  }

  static String formatWithCountryCode(String input) {
    final digits = input.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.startsWith('250') && digits.length == 12) {
      return '+250 ${digits.substring(3, 6)} ${digits.substring(6, 9)} ${digits.substring(9)}';
    }

    if (digits.startsWith('0') && digits.length == 10) {
      final local = digits.substring(1);
      return '+250 ${local.substring(0, 3)} ${local.substring(3, 6)} ${local.substring(6)}';
    }

    if (digits.length == rwandaLocalLength) {
      return '+250 ${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
    }

    return input;
  }

  static bool isValidRwandanNumber(String input) {
    final digits = input.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.startsWith('250') && digits.length == 12) return true;
    if (digits.startsWith('0') && digits.length == 10) return true;
    if (digits.length == rwandaLocalLength &&
        (digits.startsWith('7') || digits.startsWith('8'))) {
      return true;
    }

    return false;
  }

  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!isValidRwandanNumber(value)) {
      return 'Enter a valid Rwandan phone number';
    }
    return null;
  }
}
