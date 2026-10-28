enum PasswordStrength { weak, fair, strong }

class PasswordStrengthChecker {
  PasswordStrengthChecker._();

  static PasswordStrength check(String password) {
    if (password.length < 6) return PasswordStrength.weak;

    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    if (score >= 4) return PasswordStrength.strong;
    if (score >= 2) return PasswordStrength.fair;
    return PasswordStrength.weak;
  }

  static String label(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.fair:
        return 'Fair';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }
}
