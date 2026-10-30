import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_find/core/utils/profile_completion.dart';
import 'package:pharma_find/data/models/user_model.dart';

void main() {
  group('ProfileCompletion', () {
    test('returns 0.4 for user with only name and email', () {
      final user = UserModel(
        uid: 'u1',
        email: 'test@example.com',
        displayName: 'Test',
        createdAt: DateTime.now(),
      );
      expect(ProfileCompletion.percentage(user), closeTo(0.4, 0.01));
    });

    test('returns 1.0 for fully filled profile', () {
      final user = UserModel(
        uid: 'u1',
        email: 'test@example.com',
        displayName: 'Test User',
        phone: '+250781234567',
        insuranceProvider: 'RSSB',
        insuranceId: 'INS-001',
        createdAt: DateTime.now(),
      );
      expect(ProfileCompletion.percentage(user), 1.0);
      expect(ProfileCompletion.isComplete(user), true);
    });

    test('lists missing fields', () {
      final user = UserModel(
        uid: 'u1',
        email: 'test@example.com',
        displayName: 'Test',
        createdAt: DateTime.now(),
      );
      final missing = ProfileCompletion.missingFields(user, 'en');
      expect(missing, contains('phone'));
      expect(missing, contains('insurance_provider'));
      expect(missing, contains('insurance_id'));
      expect(missing.length, 3);
    });

    test('isComplete returns false for partial profile', () {
      final user = UserModel(
        uid: 'u1',
        email: 'test@example.com',
        displayName: 'Test',
        phone: '+250781234567',
        createdAt: DateTime.now(),
      );
      expect(ProfileCompletion.isComplete(user), false);
    });
  });
}
