class AuthConstants {
  AuthConstants._();

  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int maxEmailLength = 254;
  static const int maxNameLength = 100;
  static const int sessionTimeoutMinutes = 30;

  static const String defaultRole = 'patient';
  static const String partnerRole = 'partner';

  static const List<String> supportedRoles = [defaultRole, partnerRole];

  static const Duration authDelay = Duration(milliseconds: 400);
  static const Duration resetDelay = Duration(milliseconds: 300);
}
