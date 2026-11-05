import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_find/presentation/mixins/auth_form_mixin.dart';

class _TestWidget extends StatefulWidget {
  const _TestWidget();
  @override
  State<_TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<_TestWidget> with AuthFormMixin<_TestWidget> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: TextFormField(
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
      ),
    );
  }
}

void main() {
  group('AuthFormMixin', () {
    testWidgets('validateForm returns false on invalid input', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: _TestWidget())));

      final state = tester.state<_TestWidgetState>(find.byType(_TestWidget));
      expect(state.validateForm(), isFalse);
    });
  });
}
