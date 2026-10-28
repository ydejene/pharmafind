import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_find/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('creates instance with required fields', () {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(user.uid, 'test-uid');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.role, 'patient');
      expect(user.insuranceProvider, isNull);
    });

    test('copyWith returns new instance with updated fields', () {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: DateTime(2024, 1, 1),
      );

      final updated = user.copyWith(
        displayName: 'New Name',
        insuranceProvider: 'RSSB',
      );

      expect(updated.displayName, 'New Name');
      expect(updated.insuranceProvider, 'RSSB');
      expect(updated.uid, 'test-uid');
      expect(updated.email, 'test@example.com');
    });
  });
}
