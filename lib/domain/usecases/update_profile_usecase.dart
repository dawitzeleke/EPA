import '../entities/update_profile_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for updating customer profile
class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<UpdateProfileResponseEntity> execute({
    required String id,
    required String fullName,
    String? currentPassword,
    String? newPassword,
    String? confirmPassword,
  }) async {
    final trimmedName = fullName.trim();
    if (trimmedName.isEmpty) {
      throw Exception('Name cannot be empty');
    }

    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw Exception('Missing user id');
    }

    if ((currentPassword?.isNotEmpty ?? false) ||
        (newPassword?.isNotEmpty ?? false) ||
        (confirmPassword?.isNotEmpty ?? false)) {
      final currentPwd = currentPassword?.trim() ?? '';
      final newPwd = newPassword?.trim() ?? '';
      final confirmPwd = confirmPassword?.trim() ?? '';

      if (currentPwd.isEmpty || newPwd.isEmpty || confirmPwd.isEmpty) {
        throw Exception('All password fields are required.');
      }

      if (newPwd != confirmPwd) {
        throw Exception('New password and confirmation do not match.');
      }
    }

    final entity = UpdateProfileEntity(
      id: trimmedId,
      fullName: trimmedName,
      currentPassword: currentPassword?.trim(),
      newPassword: newPassword?.trim(),
      confirmPassword: confirmPassword?.trim(),
    );

    return await repository.updateProfile(entity);
  }
}
