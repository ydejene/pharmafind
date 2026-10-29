import '../constants/auth_constants.dart';

class SessionService {
  DateTime? _lastActivity;
  bool _rememberMe = false;

  bool get isSessionExpired {
    if (_rememberMe) return false;
    if (_lastActivity == null) return true;
    final elapsed = DateTime.now().difference(_lastActivity!);
    return elapsed.inMinutes >= AuthConstants.sessionTimeoutMinutes;
  }

  void recordActivity() {
    _lastActivity = DateTime.now();
  }

  void setRememberMe(bool value) {
    _rememberMe = value;
  }

  bool get rememberMe => _rememberMe;

  Duration? get timeUntilExpiry {
    if (_rememberMe || _lastActivity == null) return null;
    final elapsed = DateTime.now().difference(_lastActivity!);
    final remaining = Duration(minutes: AuthConstants.sessionTimeoutMinutes) - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  void clearSession() {
    _lastActivity = null;
    _rememberMe = false;
  }
}
