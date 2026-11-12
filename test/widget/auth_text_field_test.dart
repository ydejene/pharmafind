import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmafind/presentation/widgets/auth_text_field.dart';

void main() {
  group('AuthTextField', () {
    testWidgets('renders label and hint', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(
              controller: controller,
              label: 'Email',
              hint: 'you@example.com',
              prefixIcon: Icons.email_outlined,
            ),
          ),
        ),
      );

      expect(find.text('EMAIL'), findsOneWidget);
      expect(find.text('you@example.com'), findsOneWidget);
    });

    testWidgets('shows validation error on empty submit', (tester) async {
      final controller = TextEditingController();
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: AuthTextField(
                controller: controller,
                label: 'Email',
                hint: 'you@example.com',
                prefixIcon: Icons.email_outlined,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
            ),
          ),
        ),
      );

      formKey.currentState!.validate();
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);
    });
  });
}
