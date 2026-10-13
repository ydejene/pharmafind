import '../../repositories/auth_repository.dart';

class SendPasswordResetUseCase {
  final IAuthRepository repository;

  SendPasswordResetUseCase(this.repository);

  Future<void> call(String email) {
    return repository.sendPasswordReset(email);
  }
}
