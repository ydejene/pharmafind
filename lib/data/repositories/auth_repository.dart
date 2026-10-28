import '../../core/constants/auth_constants.dart';
import '../../core/exceptions/auth_exception.dart';
import '../models/user_model.dart';

class AuthRepository {
  final Map<String, UserModel> _registeredUsers = {};
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<UserModel> signInWithEmail(String email, String password) async {
    await Future.delayed(AuthConstants.authDelay);
    final normalizedEmail = email.trim().toLowerCase();

    final existing = _registeredUsers[normalizedEmail];
    if (existing != null) {
      _currentUser = existing;
      return _currentUser!;
    }

    _currentUser = UserModel(
      uid: 'user-${normalizedEmail.hashCode.abs()}',
      email: normalizedEmail,
      displayName: normalizedEmail.split('@').first,
      createdAt: DateTime.now(),
    );
    _registeredUsers[normalizedEmail] = _currentUser!;
    return _currentUser!;
  }

  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    String role = 'patient',
  }) async {
    await Future.delayed(AuthConstants.authDelay);
    final normalizedEmail = email.trim().toLowerCase();

    if (_registeredUsers.containsKey(normalizedEmail)) {
      throw AuthException.emailAlreadyInUse();
    }

    if (password.length < AuthConstants.minPasswordLength) {
      throw AuthException.weakPassword();
    }

    _currentUser = UserModel(
      uid: 'user-${DateTime.now().millisecondsSinceEpoch}',
      email: normalizedEmail,
      displayName: displayName.trim(),
      role: role,
      createdAt: DateTime.now(),
    );
    _registeredUsers[normalizedEmail] = _currentUser!;
    return _currentUser!;
  }

  Future<UserModel> signInWithGoogle() async {
    await Future.delayed(AuthConstants.authDelay);
    _currentUser = UserModel(
      uid: 'google-user-001',
      email: 'demo@gmail.com',
      displayName: 'Demo User',
      createdAt: DateTime.now(),
    );
    return _currentUser!;
  }

  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(AuthConstants.resetDelay);
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      throw AuthException.userNotFound();
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
  }

  Future<UserModel?> getCurrentUserModel() async {
    return _currentUser;
  }

  Future<void> updateUserProfile(UserModel userModel) async {
    _currentUser = userModel;
    _registeredUsers[userModel.email] = userModel;
  }
}
