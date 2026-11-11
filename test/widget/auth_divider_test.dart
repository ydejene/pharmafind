import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_find/presentation/widgets/auth_divider.dart';

void main() {
  group('AuthDivider', () {
    testWidgets('renders separator text between dividers', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuthDivider(text: 'or continue with'),
          ),
        ),
      );

      expect(find.text('or continue with'), findsOneWidget);
      expect(find.byType(Divider), findsNWidgets(2));
    });
  });
}
