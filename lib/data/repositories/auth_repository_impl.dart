import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthDataSource datasource;

  AuthRepositoryImpl({required this.datasource});

  @override
  Future<UserEntity> signInWithEmail(String email, String password) async {
    final model = await datasource.signInWithEmail(email, password);
    return model.toEntity();
  }

  @override
  Future<UserEntity> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    String role = 'patient',
  }) async {
    final model = await datasource.registerWithEmail(
      email: email,
      password: password,
      displayName: displayName,
      role: role,
    );
    return model.toEntity();
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    final model = await datasource.signInWithGoogle();
    return model.toEntity();
  }

  @override
  Future<void> sendPasswordReset(String email) {
    return datasource.sendPasswordReset(email);
  }

  @override
  Future<void> signOut() {
    return datasource.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final model = await datasource.getCurrentUser();
    return model?.toEntity();
  }

  @override
  Future<void> updateUserProfile(UserEntity user) {
    return datasource.updateUserProfile(UserModel.fromEntity(user));
  }
}
