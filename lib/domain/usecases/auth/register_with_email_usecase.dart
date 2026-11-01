import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class RegisterWithEmailUseCase {
  final IAuthRepository repository;

  RegisterWithEmailUseCase(this.repository);

  Future<UserEntity> call({
    required String email,
    required String password,
    required String displayName,
    String role = 'patient',
  }) {
    return repository.registerWithEmail(
      email: email,
      password: password,
      displayName: displayName,
      role: role,
    );
  }
}
