import 'package:flutter_test/flutter_test.dart';
import 'package:pharmafind/domain/entities/user_entity.dart';

void main() {
  group('UserEntity', () {
    final user = UserEntity(
      uid: 'test-uid',
      email: 'test@example.com',
      displayName: 'Test User',
      createdAt: DateTime(2024, 1, 1),
    );

    test('default role is patient', () {
      expect(user.role, 'patient');
      expect(user.isPatient, isTrue);
      expect(user.isPartner, isFalse);
      expect(user.isAdmin, isFalse);
    });

    test('partner role detected correctly', () {
      final partner = UserEntity(
        uid: 'p1',
        email: 'p@example.com',
        displayName: 'Partner',
        role: 'partner',
        createdAt: DateTime(2024, 1, 1),
      );
      expect(partner.isPartner, isTrue);
      expect(partner.isPatient, isFalse);
    });

    test('copyWith preserves uid', () {
      final updated = user.copyWith(displayName: 'New Name');
      expect(updated.uid, user.uid);
      expect(updated.displayName, 'New Name');
    });

    test('equality based on props', () {
      final same = UserEntity(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: DateTime(2024, 1, 1),
      );
      expect(user, equals(same));
    });
  });
}
