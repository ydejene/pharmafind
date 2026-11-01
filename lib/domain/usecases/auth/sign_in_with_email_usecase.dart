import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class SignInWithEmailUseCase {
  final IAuthRepository repository;

  SignInWithEmailUseCase(this.repository);

  Future<UserEntity> call(String email, String password) {
    return repository.signInWithEmail(email, password);
  }
}
