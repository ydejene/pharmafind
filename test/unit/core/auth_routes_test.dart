import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_find/core/constants/auth_routes.dart';

void main() {
  group('AuthRoutes', () {
    test('splash route is /', () {
      expect(AuthRoutes.splash, '/');
    });

    test('login route is /login', () {
      expect(AuthRoutes.login, '/login');
    });

    test('register route is /register', () {
      expect(AuthRoutes.register, '/register');
    });

    test('forgotPassword route is /forgot-password', () {
      expect(AuthRoutes.forgotPassword, '/forgot-password');
    });

    test('all routes start with /', () {
      final routes = [
        AuthRoutes.splash,
        AuthRoutes.language,
        AuthRoutes.login,
        AuthRoutes.register,
        AuthRoutes.forgotPassword,
        AuthRoutes.home,
        AuthRoutes.partnerSignup,
        AuthRoutes.profile,
      ];
      for (final route in routes) {
        expect(route.startsWith('/'), isTrue, reason: '$route should start with /');
      }
    });
  });
}
