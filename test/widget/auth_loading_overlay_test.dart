import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_find/presentation/widgets/auth_loading_overlay.dart';

void main() {
  group('AuthLoadingOverlay', () {
    testWidgets('shows child without overlay when not loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AuthLoadingOverlay(
            isLoading: false,
            child: Scaffold(body: Text('Content')),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows spinner overlay when loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AuthLoadingOverlay(
            isLoading: true,
            child: Scaffold(body: Text('Content')),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
