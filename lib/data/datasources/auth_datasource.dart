import '../models/user_model.dart';

abstract class IAuthDataSource {
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    String role = 'patient',
  });
  Future<UserModel> signInWithGoogle();
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<void> updateUserProfile(UserModel user);
}
