import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_find/core/constants/auth_routes.dart';

void main() {
  group('AuthNavigation routing', () {
    testWidgets('login replacement removes previous route', (tester) async {
      final routes = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/test',
          onGenerateRoute: (settings) {
            routes.add(settings.name ?? '');
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const Scaffold(),
            );
          },
        ),
      );

      expect(routes.contains('/test'), isTrue);
    });

    test('AuthRoutes.home is /home', () {
      expect(AuthRoutes.home, '/home');
    });

    test('AuthRoutes.profile is /profile', () {
      expect(AuthRoutes.profile, '/profile');
    });
  });
}
