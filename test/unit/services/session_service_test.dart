import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_find/core/services/session_service.dart';

void main() {
  late SessionService session;

  setUp(() {
    session = SessionService();
  });

  group('SessionService', () {
    test('starts with expired session', () {
      expect(session.isSessionExpired, true);
    });

    test('recording activity makes session valid', () {
      session.recordActivity();
      expect(session.isSessionExpired, false);
    });

    test('rememberMe bypasses expiry', () {
      session.setRememberMe(true);
      expect(session.isSessionExpired, false);
      expect(session.rememberMe, true);
    });

    test('clearSession resets everything', () {
      session.recordActivity();
      session.setRememberMe(true);
      session.clearSession();
      expect(session.isSessionExpired, true);
      expect(session.rememberMe, false);
    });

    test('timeUntilExpiry returns null when rememberMe is on', () {
      session.setRememberMe(true);
      expect(session.timeUntilExpiry, isNull);
    });

    test('timeUntilExpiry returns null when no activity recorded', () {
      expect(session.timeUntilExpiry, isNull);
    });

    test('timeUntilExpiry returns a positive duration after activity', () {
      session.recordActivity();
      final remaining = session.timeUntilExpiry;
      expect(remaining, isNotNull);
      expect(remaining!.inMinutes, greaterThan(0));
    });
  });
}
