import 'package:flutter_test/flutter_test.dart';
import 'package:pharmafind/core/constants/auth_routes.dart';

void main() {
  test('home route is registered', () {
    expect(AuthRoutes.home, '/home');
  });
}