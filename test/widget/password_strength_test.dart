import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_find/presentation/widgets/password_strength_indicator.dart';

void main() {
  group('PasswordStrengthIndicator', () {
    testWidgets('hidden when password is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordStrengthIndicator(password: ''),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('shows Weak for short password', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordStrengthIndicator(password: 'abc123'),
          ),
        ),
      );

      expect(find.text('Weak'), findsOneWidget);
    });

    testWidgets('shows Strong for complex password', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordStrengthIndicator(password: 'MyP@ssw0rd!123'),
          ),
        ),
      );

      expect(find.text('Strong'), findsOneWidget);
    });
  });
}
