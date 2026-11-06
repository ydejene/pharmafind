class EmailUtils {
  EmailUtils._();

  static String normalize(String email) {
    return email.trim().toLowerCase();
  }

  static String? extractDomain(String email) {
    final parts = email.split('@');
    return parts.length == 2 ? parts[1] : null;
  }

  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final local = parts[0];
    final domain = parts[1];
    if (local.length <= 2) return '**@$domain';
    return '${local[0]}${'*' * (local.length - 2)}${local[local.length - 1]}@$domain';
  }
}
