import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmafind/presentation/widgets/auth_header.dart';

void main() {
  group('AuthHeader', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuthHeader(title: 'Welcome Back'),
          ),
        ),
      );

      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('renders eyebrow when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuthHeader(
              eyebrow: 'GET STARTED',
              title: 'Sign Up',
            ),
          ),
        ),
      );

      expect(find.text('GET STARTED'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuthHeader(
              title: 'Reset Password',
              subtitle: 'Enter your email to receive a reset link',
            ),
          ),
        ),
      );

      expect(find.text('Reset Password'), findsOneWidget);
      expect(
        find.text('Enter your email to receive a reset link'),
        findsOneWidget,
      );
    });
  });
}
