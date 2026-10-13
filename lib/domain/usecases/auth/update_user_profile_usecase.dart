import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class UpdateUserProfileUseCase {
  final IAuthRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<void> call(UserEntity user) {
    return repository.updateUserProfile(user);
  }
}
