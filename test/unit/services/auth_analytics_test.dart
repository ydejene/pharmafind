import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_find/core/services/auth_analytics.dart';

void main() {
  setUp(() {
    AuthAnalytics.clear();
  });

  group('AuthAnalytics', () {
    test('starts with empty events', () {
      expect(AuthAnalytics.events, isEmpty);
    });

    test('logLoginAttempt adds event', () {
      AuthAnalytics.logLoginAttempt(method: 'email');
      expect(AuthAnalytics.events.length, 1);
      expect(AuthAnalytics.events.first.type, AuthEventType.loginAttempt);
      expect(AuthAnalytics.events.first.method, 'email');
    });

    test('logLoginSuccess records user and method', () {
      AuthAnalytics.logLoginSuccess(method: 'google', userId: 'u123');
      final event = AuthAnalytics.events.first;
      expect(event.type, AuthEventType.loginSuccess);
      expect(event.userId, 'u123');
      expect(event.method, 'google');
    });

    test('logLoginFailure records error', () {
      AuthAnalytics.logLoginFailure(
        method: 'email',
        error: 'invalid-credentials',
      );
      expect(AuthAnalytics.events.first.error, 'invalid-credentials');
    });

    test('logRegistration records userId', () {
      AuthAnalytics.logRegistration(userId: 'new-user');
      expect(AuthAnalytics.events.first.type, AuthEventType.registration);
    });

    test('logLogout records userId', () {
      AuthAnalytics.logLogout(userId: 'u123');
      expect(AuthAnalytics.events.first.type, AuthEventType.logout);
    });

    test('logPasswordReset records event', () {
      AuthAnalytics.logPasswordReset(email: 'test@example.com');
      expect(AuthAnalytics.events.first.type, AuthEventType.passwordReset);
    });

    test('clear removes all events', () {
      AuthAnalytics.logLoginAttempt(method: 'email');
      AuthAnalytics.logRegistration(userId: 'u1');
      expect(AuthAnalytics.events.length, 2);
      AuthAnalytics.clear();
      expect(AuthAnalytics.events, isEmpty);
    });

    test('events list is unmodifiable', () {
      AuthAnalytics.logLoginAttempt(method: 'email');
      expect(
        () => AuthAnalytics.events.add(
          AuthAnalyticsEvent(
            type: AuthEventType.logout,
            timestamp: DateTime.now(),
          ),
        ),
        throwsUnsupportedError,
      );
    });
  });
}
