import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmafind/presentation/widgets/terms_checkbox.dart';

void main() {
  group('TermsCheckbox', () {
    testWidgets('renders unchecked by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TermsCheckbox(
              value: false,
              onChanged: (_) {},
              locale: 'en',
            ),
          ),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
    });

    testWidgets('calls onChanged when tapped', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TermsCheckbox(
              value: false,
              onChanged: (v) => result = v,
              locale: 'en',
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      expect(result, isTrue);
    });
  });
}
