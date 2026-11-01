import '../entities/user_entity.dart';

abstract class IAuthRepository {
  Future<UserEntity> signInWithEmail(String email, String password);
  Future<UserEntity> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    String role = 'patient',
  });
  Future<UserEntity> signInWithGoogle();
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
  Future<UserEntity?> getCurrentUser();
  Future<void> updateUserProfile(UserEntity user);
}
