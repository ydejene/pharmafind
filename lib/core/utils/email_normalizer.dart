class EmailNormalizer {
  EmailNormalizer._();

  static String normalize(String email) {
    return email.trim().toLowerCase();
  }

  static bool isValidFormat(String email) {
    final normalized = normalize(email);
    if (normalized.isEmpty) return false;
    final parts = normalized.split('@');
    if (parts.length != 2) return false;
    if (parts[0].isEmpty || parts[1].isEmpty) return false;
    return parts[1].contains('.');
  }

  static String? getDomain(String email) {
    final normalized = normalize(email);
    final parts = normalized.split('@');
    return parts.length == 2 ? parts[1] : null;
  }
}
