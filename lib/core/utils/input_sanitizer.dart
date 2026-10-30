class InputSanitizer {
  InputSanitizer._();

  static String sanitizeName(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .split(' ')
        .map((word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  static String sanitizeEmail(String input) {
    return input.trim().toLowerCase();
  }

  static String sanitizePhone(String input) {
    return input.replaceAll(RegExp(r'[^\d+]'), '');
  }

  static String removeExcessiveWhitespace(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String stripHtml(String input) {
    return input.replaceAll(RegExp(r'<[^>]*>'), '');
  }
}
