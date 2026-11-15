import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmafind/presentation/widgets/social_sign_in_button.dart';

void main() {
  group('SocialSignInButton', () {
    testWidgets('renders icon and label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialSignInButton(
              icon: Icons.g_mobiledata,
              label: 'Sign in with Google',
              isLoading: false,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.byIcon(Icons.g_mobiledata), findsOneWidget);
    });

    testWidgets('disables button when loading', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialSignInButton(
              icon: Icons.g_mobiledata,
              label: 'Google',
              isLoading: true,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      expect(tapped, isFalse);
    });
  });
}
