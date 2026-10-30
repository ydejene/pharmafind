class AuthAnalytics {
  static final List<AuthAnalyticsEvent> _events = [];

  static List<AuthAnalyticsEvent> get events => List.unmodifiable(_events);

  static void logLoginAttempt({required String method}) {
    _events.add(AuthAnalyticsEvent(
      type: AuthEventType.loginAttempt,
      method: method,
      timestamp: DateTime.now(),
    ));
  }

  static void logLoginSuccess({required String method, required String userId}) {
    _events.add(AuthAnalyticsEvent(
      type: AuthEventType.loginSuccess,
      method: method,
      userId: userId,
      timestamp: DateTime.now(),
    ));
  }

  static void logLoginFailure({required String method, required String error}) {
    _events.add(AuthAnalyticsEvent(
      type: AuthEventType.loginFailure,
      method: method,
      error: error,
      timestamp: DateTime.now(),
    ));
  }

  static void logRegistration({required String userId}) {
    _events.add(AuthAnalyticsEvent(
      type: AuthEventType.registration,
      userId: userId,
      timestamp: DateTime.now(),
    ));
  }

  static void logLogout({required String userId}) {
    _events.add(AuthAnalyticsEvent(
      type: AuthEventType.logout,
      userId: userId,
      timestamp: DateTime.now(),
    ));
  }

  static void logPasswordReset({required String email}) {
    _events.add(AuthAnalyticsEvent(
      type: AuthEventType.passwordReset,
      timestamp: DateTime.now(),
    ));
  }

  static void clear() => _events.clear();
}

enum AuthEventType {
  loginAttempt,
  loginSuccess,
  loginFailure,
  registration,
  logout,
  passwordReset,
}

class AuthAnalyticsEvent {
  final AuthEventType type;
  final String? method;
  final String? userId;
  final String? error;
  final DateTime timestamp;

  const AuthAnalyticsEvent({
    required this.type,
    this.method,
    this.userId,
    this.error,
    required this.timestamp,
  });
}
