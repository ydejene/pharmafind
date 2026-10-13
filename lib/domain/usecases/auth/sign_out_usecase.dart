import '../../repositories/auth_repository.dart';

class SignOutUseCase {
  final IAuthRepository repository;

  SignOutUseCase(this.repository);

  Future<void> call() {
    return repository.signOut();
  }
}
