import '../models/user_model.dart';

class AuthRepository {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  Future<UserModel> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _currentUser = UserModel(
      uid: 'user-${email.hashCode.abs()}',
      email: email.trim(),
      displayName: email.split('@').first,
      createdAt: DateTime.now(),
    );
    return _currentUser!;
  }

  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    String role = 'patient',
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _currentUser = UserModel(
      uid: 'user-${DateTime.now().millisecondsSinceEpoch}',
      email: email.trim(),
      displayName: displayName,
      role: role,
      createdAt: DateTime.now(),
    );
    return _currentUser!;
  }

  Future<UserModel> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 400));
    _currentUser = UserModel(
      uid: 'google-user-001',
      email: 'demo@gmail.com',
      displayName: 'Demo User',
      createdAt: DateTime.now(),
    );
    return _currentUser!;
  }

  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> signOut() async {
    _currentUser = null;
  }

  Future<UserModel?> getCurrentUserModel() async {
    return _currentUser;
  }

  Future<void> updateUserProfile(UserModel userModel) async {
    _currentUser = userModel;
  }
}
