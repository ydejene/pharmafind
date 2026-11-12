import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmafind/presentation/widgets/auth_submit_button.dart';

void main() {
  group('AuthSubmitButton', () {
    testWidgets('renders label when not loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthSubmitButton(
              label: 'Sign In',
              isLoading: false,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Sign In'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows spinner when loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthSubmitButton(
              label: 'Sign In',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Sign In'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('disables tap when loading', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthSubmitButton(
              label: 'Sign In',
              isLoading: true,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isFalse);
    });
  });
}
